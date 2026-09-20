variable "REDACTED_f03c8bab" {
  description = "ModSecurity mode: DetectionOnly (log) or On (BLOCK). notrf01 runs On (MESHSAT-1207) because its ingress carries the public SaaS. NL/GR stay DetectionOnly: their ingress is internal ops names behind the ASA, their traffic is machine-to-machine (S3 sigv4 PUTs, remote-write protobuf, ArgoCD gRPC) which is exactly what CRS is worst at, and ModSecurity has ALREADY broken a restore here - the seaweedfs-s3 ingress carries enable-modsecurity=false because the body filter truncated a 2 GB barman restore at exactly 512 MiB. Do not flip this without explicit operator instruction (root CLAUDE.md, Things to Never Do)."
  type        = string
  default     = "DetectionOnly"
}

variable "REDACTED_14740f3f" {
  description = "Extra SecRule lines appended to the snippet, per site. notrf01 uses two, and BOTH are load-bearing there: id:1000 holds /api/webhook/ in DetectionOnly so a CRS false positive can never drop a satellite SOS or a Stripe webhook, and id:1001 applies ctl:ruleRemoveById=911100 because CRS's default allowed_methods has no PUT/DELETE and the Hub REST API uses both. ⚠ Keep this EMPTY where the engine is DetectionOnly: 1001 would silently pre-authorise a permissive method policy for the day that site ever flips to On. HOW to express them, learned the hard way on 2026-09-17: use `ctl:ruleRemoveById`, NOT `setvar:'tx.allowed_methods=...'` (ingress-nginx wraps the snippet in `modsecurity_rules '...'`, so the inner single quotes terminate nginx's string and BOTH controllers refuse the reload) and NOT `SecRuleRemoveById` (the rule must already be parsed, and this snippet is included BEFORE the CRS rules file). Do not host-scope 1001 either: the Hub reaches authentik through its PUBLIC hostname, so a host-scoped rule still 403s its PATCH/DELETE on auth.meshsat.net."
  type        = string
  default     = ""
}

# =============================================================================
# Variables for Ingress NGINX Controller
# =============================================================================

variable "REDACTED_3b82c3d6" {
  description = "Default SSL certificate for ingress (namespace/secret-name)"
  type        = string
  default     = "REDACTED_f89271df"
}

variable "csp_header" {
  description = "Content-Security-Policy value for the global addHeaders block. Empty string omits the header (for sites whose applications own their CSP). frame-ancestors includes matrix.example.net for Grafana embedding (single estate-wide instance)."
  type        = string
  default     = "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self' wss:; frame-ancestors 'self' https://matrix.example.net vector://vector; base-uri 'self'; form-action 'self';"
}
