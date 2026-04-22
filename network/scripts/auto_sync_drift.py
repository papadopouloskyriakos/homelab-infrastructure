#!/usr/bin/env python3
"""
Auto-Sync Configuration Drift
Automatically sync device configurations to GitLab when drift is detected

This script fetches current configs from devices and updates GitLab configs,
then commits the changes. This makes the device the source of truth when
drift is detected.

Usage: auto_sync_drift.py [device_type] [device_name]

Examples:
  auto_sync_drift.py                      # Sync all drifted devices
  auto_sync_drift.py Router nl-lte01  # Sync specific device
"""
import sys
import os
import subprocess
from pathlib import Path
from netmiko import ConnectHandler

# Import centralized filter
sys.path.insert(0, os.path.dirname(__file__))
from filter_dynamic_content import DynamicContentFilter

class DriftSyncer:
    """Sync device configurations to GitLab"""
    
    def __init__(self):
        self.synced_devices = []
        self.failed_devices = []
        self.blocked_devices = []   # Drift refused by the whitelist guardrail
        self.filter = DynamicContentFilter()  # Use centralized filter

    def check_whitelist_membership(self, gitlab_path):
        """Run ci/scripts/check-whitelist-membership.py against the just-written config.

        Returns (ok: bool, message: str). Fails CLOSED if the guardrail script
        is missing — better to block sync than silently skip the check.
        """
        script = Path("ci/scripts/check-whitelist-membership.py")
        if not script.exists():
            return False, (
                f"GUARDRAIL MISSING: {script} not found in repo. "
                "Drift-sync refuses to commit firewall configs without the guardrail."
            )
        try:
            result = subprocess.run(
                ['python3', str(script), str(gitlab_path)],
                capture_output=True, text=True, timeout=30,
            )
        except subprocess.TimeoutExpired:
            return False, f"GUARDRAIL TIMEOUT on {gitlab_path}"
        if result.returncode == 0:
            return True, ""
        msg = (result.stdout or "").strip() or (result.stderr or "").strip() or "violation"
        return False, msg
    
    def normalize_config(self, config):
        """
        Normalize config for comparison
        Uses centralized DynamicContentFilter for consistency
        """
        # Use the centralized filter
        return self.filter.filter_config(config)
    
    def fetch_device_config(self, device_type, device_name):
        """Fetch current running config from device"""
        username = os.getenv('CISCO_USER', 'kyriakosp')
        password = os.getenv('CISCO_PASSWORD')
        
        if not password:
            raise Exception("CISCO_PASSWORD environment variable not set")
        
        netmiko_type_map = {
            'Firewall': 'cisco_asa',
            'Router': 'cisco_ios',
            'Switch': 'cisco_ios',
            'Access-Point': 'cisco_ios',
        }
        
        device_type_netmiko = netmiko_type_map.get(device_type, 'cisco_ios')
        
        device_params = {
            'device_type': device_type_netmiko,
            'host': f"{device_name}.example.net",
            'username': username,
            'password': password,
            'timeout': 120,
            'fast_cli': False,
        }
        
        conn = ConnectHandler(**device_params)
        config = conn.send_command("show running-config", read_timeout=120)
        conn.disconnect()
        
        return config
    
    def check_has_drift(self, device_type, device_name):
        """Check if device has drift"""
        try:
            device_config = self.fetch_device_config(device_type, device_name)
            
            gitlab_path = Path(f"network/configs/{device_type}/{device_name}")
            
            if not gitlab_path.exists():
                # No GitLab config - this is a new device
                return True, device_config
            
            with open(gitlab_path) as f:
                gitlab_config = f.read()
            
            device_normalized = self.normalize_config(device_config)
            gitlab_normalized = self.normalize_config(gitlab_config)
            
            if device_normalized != gitlab_normalized:
                return True, device_config
            else:
                return False, None
        
        except Exception as e:
            print(f"  ERROR checking {device_name}: {str(e)[:60]}")
            return False, None
    
    def sync_device_to_gitlab(self, device_type, device_name):
        """Sync device config to GitLab"""
        print(f"Syncing {device_name}...", end=' ')
        
        try:
            # Check for drift
            has_drift, device_config = self.check_has_drift(device_type, device_name)
            
            if not has_drift:
                print("[SKIP] No drift detected")
                return True
            
            # Update GitLab config
            gitlab_path = Path(f"network/configs/{device_type}/{device_name}")
            gitlab_path.parent.mkdir(parents=True, exist_ok=True)

            with open(gitlab_path, 'w') as f:
                f.write(device_config)

            # Firewall-only: enforce NAT whitelist membership before committing
            # the drift. Blocks the same class of incident that caused the
            # 2026-04-22 rtr01 shun (transit /30 live-deployed before
            # whitelist update → ASA auto-shun on traffic burst).
            # [IFRNLLEI01PRD-699]
            if device_type.lower() == 'firewall':
                ok, msg = self.check_whitelist_membership(gitlab_path)
                if not ok:
                    # Revert the write — don't leave a dirty working tree.
                    subprocess.run(
                        ['git', 'checkout', '--', str(gitlab_path)],
                        capture_output=True,
                    )
                    print("[BLOCKED] whitelist guardrail refused drift — not committing")
                    for line in msg.splitlines()[:20]:
                        print(f"  | {line}")
                    self.blocked_devices.append((device_type, device_name, msg))
                    return False

            # Stage the file
            subprocess.run(
                ['git', 'add', str(gitlab_path)],
                check=True,
                capture_output=True
            )

            print("[SYNCED]")
            self.synced_devices.append((device_type, device_name))
            return True
        
        except Exception as e:
            print(f"[FAILED] {str(e)[:60]}")
            self.failed_devices.append((device_type, device_name, str(e)))
            return False
    
    def sync_all_devices(self):
        """Sync all devices that have drift"""
        configs_dir = Path("network/configs")
        
        if not configs_dir.exists():
            print("ERROR: network/configs/ directory not found")
            return 1
        
        print("=" * 70)
        print("AUTO-SYNC DRIFT - Device to GitLab")
        print("=" * 70)
        print()
        
        for device_type_dir in configs_dir.iterdir():
            if not device_type_dir.is_dir():
                continue
            
            device_type = device_type_dir.name
            
            # Skip non-device directories
            if device_type in ['PDU', 'UPS']:
                continue
            
            for device_file in device_type_dir.iterdir():
                if device_file.is_file() and not device_file.name.startswith('.'):
                    # Skip .gitkeep and other dotfiles — netmiko would try to SSH
                    # to a literal ".gitkeep" hostname and fail with
                    # "UnicodeError: label empty". [IFRNLLEI01PRD-702]
                    device_name = device_file.name
                    self.sync_device_to_gitlab(device_type, device_name)
        
        print()
        print("=" * 70)
        print("SYNC SUMMARY")
        print("=" * 70)
        
        if self.synced_devices:
            print(f"Synced {len(self.synced_devices)} device(s):")
            for device_type, device_name in self.synced_devices:
                print(f"  - {device_name} ({device_type})")
        else:
            print("No devices needed syncing")
        
        if self.failed_devices:
            print()
            print(f"Failed to sync {len(self.failed_devices)} device(s):")
            for device_type, device_name, error in self.failed_devices:
                print(f"  - {device_name} ({device_type})")
                print(f"    Error: {error[:70]}")

        if self.blocked_devices:
            print()
            print(f"BLOCKED by whitelist guardrail: {len(self.blocked_devices)} device(s):")
            for device_type, device_name, msg in self.blocked_devices:
                print(f"  - {device_name} ({device_type})")
                first_err = next(
                    (ln for ln in msg.splitlines() if ln.strip().startswith("line ")),
                    msg.splitlines()[0] if msg else "",
                )
                print(f"    {first_err.strip()[:100]}")
            print()
            print("ACTION REQUIRED: an RFC1918 network referenced by an outside_*")
            print("NAT rule on the LIVE device is NOT a member of")
            print("object-group whitelist_shun_nlgr_all_subnets. That subnet WILL")
            print("be auto-shunned by threat-detection on the next traffic burst.")
            print("Fix: add the subnet to gr_all_subnets / nl_all_subnets /")
            print("ALL_VPS_OVERLAY on both ASAs, `write memory`, then the next")
            print("drift-sync run will capture the change cleanly.")

        print()
        
        # Commit changes if any
        if self.synced_devices:
            print("Committing changes to GitLab...")
            
            # Create commit message
            commit_msg = "Auto-sync device configurations to GitLab\n\n"
            commit_msg += f"Synced {len(self.synced_devices)} device(s):\n"
            for device_type, device_name in self.synced_devices:
                commit_msg += f"- {device_name}\n"
            
            try:
                # Commit
                subprocess.run(
                    ['git', 'commit', '-m', commit_msg],
                    check=True,
                    capture_output=True
                )
                
                print("  Committed to local git")
                
                # Push
                subprocess.run(
                    ['git', 'push', 'origin', 'main'],
                    check=True,
                    capture_output=True
                )
                
                print("  Pushed to GitLab")
                print()
                print("SUCCESS: Device configs synced to GitLab")
                # Fall through to the guardrail-exit check below so partial
                # success (some devices synced, some blocked by the guardrail)
                # surfaces as non-zero. [IFRNLLEI01PRD-699]

            except subprocess.CalledProcessError as e:
                print(f"  ERROR: Git operation failed: {e}")
                print(f"  You may need to manually commit and push")
                return 1
        else:
            print("No changes to commit")

        # Non-zero if any device was blocked by the guardrail so the CI
        # job surfaces the failure even on partial success.
        if self.blocked_devices:
            return 2
        return 0

def main():
    """Main entry point"""
    syncer = DriftSyncer()
    
    if len(sys.argv) == 3:
        # Sync specific device
        device_type = sys.argv[1]
        device_name = sys.argv[2]
        
        success = syncer.sync_device_to_gitlab(device_type, device_name)
        
        if success and syncer.synced_devices:
            # Commit the change
            commit_msg = f"Sync {device_name} config from device to GitLab"
            
            try:
                subprocess.run(['git', 'commit', '-m', commit_msg], check=True)
                subprocess.run(['git', 'push', 'origin', 'main'], check=True)
                print()
                print("SUCCESS: Config synced and pushed to GitLab")
                sys.exit(0)
            except subprocess.CalledProcessError:
                print()
                print("ERROR: Failed to commit/push changes")
                sys.exit(1)
        elif success:
            print()
            print("No changes needed")
            sys.exit(0)
        else:
            sys.exit(1)
    
    elif len(sys.argv) == 1:
        # Sync all devices
        exit_code = syncer.sync_all_devices()
        sys.exit(exit_code)
    
    else:
        print("Usage: auto_sync_drift.py [device_type] [device_name]", file=sys.stderr)
        print("", file=sys.stderr)
        print("Examples:", file=sys.stderr)
        print("  auto_sync_drift.py                      # Sync all drifted devices", file=sys.stderr)
        print("  auto_sync_drift.py Router nl-lte01  # Sync specific device", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()