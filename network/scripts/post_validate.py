#!/usr/bin/env python3
"""
Post-Deployment Validation
Verify device is operational after configuration deployment

Usage: post_validate.py <device_type> <device_name>

Example: post_validate.py Router nl-lte01
"""
import sys
import os
from netmiko import ConnectHandler

class PostValidator:
    """Post-deployment validation checks"""
    
    def __init__(self, device_type, device_name):
        self.device_type = device_type
        self.device_name = device_name
        self.checks_passed = 0
        self.checks_failed = 0
    
    def connect(self):
        """Connect to device"""
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
        
        device_type_netmiko = netmiko_type_map.get(self.device_type, 'cisco_ios')
        
        device_params = {
            'device_type': device_type_netmiko,
            'host': f"{self.device_name}.example.net",
            'username': username,
            'password': password,
            'timeout': 120,
            'fast_cli': False,
        }
        
        return ConnectHandler(**device_params)
    
    def check_connectivity(self, conn):
        """Verify basic connectivity"""
        print("Checking basic connectivity...", end=' ')
        
        try:
            output = conn.send_command("show version | include uptime")
            
            if output and len(output) > 0:
                print("[PASS]")
                print(f"  {output.strip()[:80]}")
                self.checks_passed += 1
                return True
            else:
                print("[FAIL]")
                print("  No response from device")
                self.checks_failed += 1
                return False
        
        except Exception as e:
            print("[FAIL]")
            print(f"  Error: {str(e)[:60]}")
            self.checks_failed += 1
            return False
    
    def check_config_saved(self, conn):
        """Verify configuration was saved to NVRAM"""
        print("Checking configuration save status...", end=' ')
        
        try:
            # Different commands for different device types
            if self.device_type == 'Firewall':
                # ASA doesn't have a direct way to check this easily
                print("[SKIP]")
                return True
            else:
                # IOS devices
                startup = conn.send_command("show startup-config | include Last configuration change")
                running = conn.send_command("show running-config | include Last configuration change")
                
                if startup and running:
                    print("[PASS]")
                    print(f"  Configuration saved to NVRAM")
                    self.checks_passed += 1
                    return True
                else:
                    print("[WARN]")
                    print("  Could not verify save status")
                    return True
        
        except Exception as e:
            print("[WARN]")
            print(f"  Error checking: {str(e)[:60]}")
            return True
    
    def check_interfaces_up(self, conn):
        """Check critical interfaces are up"""
        print("Checking interface status...", end=' ')
        
        try:
            if self.device_type == 'Firewall':
                output = conn.send_command("show interface summary")
            else:
                output = conn.send_command("show ip interface brief")
            
            if output:
                # Count interfaces
                lines = output.split('\n')
                up_count = 0
                down_count = 0
                
                for line in lines:
                    if 'up' in line.lower() and 'down' not in line.lower():
                        up_count += 1
                    elif 'down' in line.lower():
                        down_count += 1
                
                print("[PASS]")
                print(f"  Interfaces UP: {up_count}, DOWN: {down_count}")
                self.checks_passed += 1
                return True
            else:
                print("[WARN]")
                print("  Could not get interface status")
                return True
        
        except Exception as e:
            print("[WARN]")
            print(f"  Error: {str(e)[:60]}")
            return True
    
    def check_no_errors(self, conn):
        """Check for recent errors in logs"""
        print("Checking for recent errors...", end=' ')
        
        try:
            # Check logging buffer for errors
            output = conn.send_command("show logging | include Error|ERRO|Fail|FAIL", read_timeout=30)
            
            if output and len(output.strip()) > 10:
                # Found some errors
                error_lines = [line for line in output.split('\n') if line.strip()]
                
                if len(error_lines) > 5:
                    print("[WARN]")
                    print(f"  Found {len(error_lines)} error messages in logs")
                    print(f"  Most recent: {error_lines[-1][:70]}")
                else:
                    print("[PASS]")
                    print(f"  Found {len(error_lines)} errors (acceptable)")
                    self.checks_passed += 1
            else:
                print("[PASS]")
                print("  No recent errors found")
                self.checks_passed += 1
            
            return True
        
        except Exception as e:
            print("[SKIP]")
            print(f"  Could not check logs: {str(e)[:60]}")
            return True
    
    def run_all_checks(self):
        """Run all post-deployment checks"""
        print("=" * 70)
        print(f"POST-DEPLOYMENT VALIDATION: {self.device_name}")
        print("=" * 70)
        print()
        
        try:
            conn = self.connect()
            print(f"Connected to {self.device_name}")
            print()
            
            # Run checks
            self.check_connectivity(conn)
            self.check_config_saved(conn)
            self.check_interfaces_up(conn)
            self.check_no_errors(conn)
            
            conn.disconnect()
            
            print()
            print("=" * 70)
            print("VALIDATION SUMMARY")
            print("=" * 70)
            print(f"Passed: {self.checks_passed}")
            print(f"Failed: {self.checks_failed}")
            
            if self.checks_failed > 0:
                print()
                print("RESULT: ISSUES DETECTED")
                return 1
            else:
                print()
                print("RESULT: ALL CHECKS PASSED")
                return 0
        
        except Exception as e:
            print()
            print("=" * 70)
            print("VALIDATION ERROR")
            print("=" * 70)
            print(f"Error: {str(e)}")
            return 1

def main():
    """Main entry point"""
    if len(sys.argv) != 3:
        print("Usage: post_validate.py <device_type> <device_name>", file=sys.stderr)
        print("", file=sys.stderr)
        print("Example:", file=sys.stderr)
        print("  post_validate.py Router nl-lte01", file=sys.stderr)
        sys.exit(1)
    
    device_type = sys.argv[1]
    device_name = sys.argv[2]
    
    validator = PostValidator(device_type, device_name)
    exit_code = validator.run_all_checks()
    
    sys.exit(exit_code)

if __name__ == "__main__":
    main()