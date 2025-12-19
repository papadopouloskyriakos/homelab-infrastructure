# ========================================================================
# Tetragon TracingPolicies - Observe-Only Security Monitoring
# ========================================================================
# These policies provide security visibility WITHOUT enforcement
# All policies are observe-only: no Sigkill, no Override actions
# Events flow to Loki via Promtail for alerting in Grafana
# ========================================================================

# ========================================================================
# Policy 1: Process Execution Monitoring
# ========================================================================
# Monitors all process executions across the cluster
# Useful for detecting: reverse shells, unexpected binaries, crypto miners
# ========================================================================
resource "kubernetes_manifest" "REDACTED_f3167a87" {
  count = var.REDACTED_8a8d8279 ? 1 : 0

  depends_on = [helm_release.tetragon]

  manifest = {
    apiVersion = "cilium.io/v1alpha1"
    kind       = "TracingPolicy"
    metadata = {
      name = "REDACTED_de85e9d6"
      labels = {
        "app.kubernetes.io/name"       = "tetragon-policy"
        "app.kubernetes.io/component"  = "REDACTED_fd63afa2"
        "app.kubernetes.io/managed-by" = "opentofu"
        "policy.tetragon.io/type"      = "observe-only"
      }
    }
    spec = {
      # Monitor process executions via tracepoint
      tracepoints = [
        {
          subsystem = "raw_syscalls"
          event     = "sys_enter"
          args = [
            {
              index = 4
              type  = "syscall64"
            }
          ]
          selectors = [
            {
              matchArgs = [
                {
                  index    = 0
                  operator = "Equal"
                  values   = ["59"] # execve syscall number
                }
              ]
            }
          ]
        }
      ]
    }
  }
}

# ========================================================================
# Policy 2: Sensitive File Access Monitoring
# ========================================================================
# Monitors read/write access to sensitive files
# Detects: credential theft, config tampering, SSH key access
# ========================================================================
resource "kubernetes_manifest" "REDACTED_f3d5149d" {
  count = var.REDACTED_ca9faf45 ? 1 : 0

  depends_on = [helm_release.tetragon]

  manifest = {
    apiVersion = "cilium.io/v1alpha1"
    kind       = "TracingPolicy"
    metadata = {
      name = "REDACTED_8cae118b"
      labels = {
        "app.kubernetes.io/name"       = "tetragon-policy"
        "app.kubernetes.io/component"  = "REDACTED_fd63afa2"
        "app.kubernetes.io/managed-by" = "opentofu"
        "policy.tetragon.io/type"      = "observe-only"
      }
    }
    spec = {
      kprobes = [
        {
          call    = "REDACTED_cf8d91db"
          syscall = false
          return  = true
          args = [
            {
              index = 0
              type  = "file"
            },
            {
              index = 1
              type  = "int"
            }
          ]
          returnArg = {
            index = 0
            type  = "int"
          }
          returnArgAction = "Post"
          selectors = [
            {
              matchArgs = [
                {
                  index    = 0
                  operator = "Prefix"
                  values = [
                    # Authentication & credentials
                    "/etc/shadow",
                    "/etc/passwd",
                    "/etc/sudoers",
                    "/etc/pam.conf",
                    "/etc/pam.d/",
                    "/etc/security/",
                    # SSH keys and config
                    "/root/.ssh/",
                    "/home/*/.ssh/",
                    "/etc/ssh/",
                    # Kubernetes secrets (if mounted)
                    "/var/run/secrets/kubernetes.io/",
                    # Shell configs (persistence mechanisms)
                    "/etc/profile",
                    "/etc/bashrc",
                    "/etc/bash.bashrc",
                    "/root/.bashrc",
                    "/root/.profile",
                    # Boot and system
                    "/boot/",
                    "/etc/crontab",
                    "/etc/cron.d/",
                    "/var/spool/cron/",
                  ]
                }
              ]
            }
          ]
        },
        # Also monitor mmap (memory-mapped file access)
        {
          call    = "security_mmap_file"
          syscall = false
          return  = true
          args = [
            {
              index = 0
              type  = "file"
            },
            {
              index = 1
              type  = "uint32"
            }
          ]
          returnArg = {
            index = 0
            type  = "int"
          }
          returnArgAction = "Post"
          selectors = [
            {
              matchArgs = [
                {
                  index    = 0
                  operator = "Prefix"
                  values = [
                    "/etc/shadow",
                    "/etc/passwd",
                    "/etc/sudoers",
                  ]
                }
              ]
            }
          ]
        }
      ]
    }
  }
}

# ========================================================================
# Policy 3: Privileged Process Monitoring
# ========================================================================
# Monitors processes gaining or using elevated privileges
# Detects: privilege escalation, capability abuse, setuid binaries
# ========================================================================
resource "kubernetes_manifest" "REDACTED_827df794" {
  count = var.REDACTED_f45ec1ce ? 1 : 0

  depends_on = [helm_release.tetragon]

  manifest = {
    apiVersion = "cilium.io/v1alpha1"
    kind       = "TracingPolicy"
    metadata = {
      name = "REDACTED_bbe670ef"
      labels = {
        "app.kubernetes.io/name"       = "tetragon-policy"
        "app.kubernetes.io/component"  = "REDACTED_fd63afa2"
        "app.kubernetes.io/managed-by" = "opentofu"
        "policy.tetragon.io/type"      = "observe-only"
      }
    }
    spec = {
      kprobes = [
        # Monitor setuid calls
        {
          call    = "__x64_sys_setuid"
          syscall = true
          args = [
            {
              index = 0
              type  = "int"
            }
          ]
        },
        # Monitor setgid calls
        {
          call    = "__x64_sys_setgid"
          syscall = true
          args = [
            {
              index = 0
              type  = "int"
            }
          ]
        },
        # Monitor capability changes
        {
          call    = "cap_capable"
          syscall = false
          args = [
            {
              index = 0
              type  = "nop"
            },
            {
              index = 1
              type  = "user_namespace"
            },
            {
              index = 2
              type  = "int"
            }
          ]
          selectors = [
            {
              matchArgs = [
                {
                  index    = 2
                  operator = "Equal"
                  values = [
                    "21", # CAP_SYS_ADMIN
                    "23", # CAP_SYS_RAWIO
                    "24", # CAP_SYS_CHROOT
                    "25", # CAP_SYS_PTRACE
                    "38", # CAP_SETFCAP
                  ]
                }
              ]
            }
          ]
        }
      ]
    }
  }
}

# ========================================================================
# Policy 4: kubectl exec Monitoring
# ========================================================================
# Monitors interactive shell access to containers
# Critical for: audit trails, detecting unauthorized access
# ========================================================================
resource "kubernetes_manifest" "REDACTED_0c258c9c" {
  count = var.REDACTED_936fa359 ? 1 : 0

  depends_on = [helm_release.tetragon]

  manifest = {
    apiVersion = "cilium.io/v1alpha1"
    kind       = "TracingPolicy"
    metadata = {
      name = "REDACTED_e2274e6a"
      labels = {
        "app.kubernetes.io/name"       = "tetragon-policy"
        "app.kubernetes.io/component"  = "REDACTED_fd63afa2"
        "app.kubernetes.io/managed-by" = "opentofu"
        "policy.tetragon.io/type"      = "observe-only"
      }
    }
    spec = {
      kprobes = [
        {
          call    = "REDACTED_cf8d91db"
          syscall = false
          return  = true
          args = [
            {
              index = 0
              type  = "file"
            },
            {
              index = 1
              type  = "int"
            }
          ]
          returnArg = {
            index = 0
            type  = "int"
          }
          returnArgAction = "Post"
          selectors = [
            {
              # Match common shells started by kubectl exec
              matchBinaries = [
                {
                  operator = "In"
                  values = [
                    "/bin/sh",
                    "/bin/bash",
                    "/bin/zsh",
                    "/bin/ash",
                    "/usr/bin/sh",
                    "/usr/bin/bash",
                    "/usr/bin/zsh",
                  ]
                }
              ]
            }
          ]
        }
      ]
    }
  }
}

# ========================================================================
# Policy 5: Network Connection Monitoring (Optional)
# ========================================================================
# Monitors outbound network connections from pods
# Useful for: detecting C2 communication, data exfiltration
# NOTE: Can be noisy - disabled by default
# ========================================================================
resource "kubernetes_manifest" "REDACTED_97012cc7" {
  count = var.REDACTED_073bcdbd ? 1 : 0

  depends_on = [helm_release.tetragon]

  manifest = {
    apiVersion = "cilium.io/v1alpha1"
    kind       = "TracingPolicy"
    metadata = {
      name = "network-connection-monitor"
      labels = {
        "app.kubernetes.io/name"       = "tetragon-policy"
        "app.kubernetes.io/component"  = "REDACTED_fd63afa2"
        "app.kubernetes.io/managed-by" = "opentofu"
        "policy.tetragon.io/type"      = "observe-only"
      }
    }
    spec = {
      kprobes = [
        {
          call    = "tcp_connect"
          syscall = false
          args = [
            {
              index = 0
              type  = "sock"
            }
          ]
        }
      ]
    }
  }
}
