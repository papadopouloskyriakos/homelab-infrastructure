# ARTEMIS BGP Hijack Detection - ArgoCD Deployment

## Overview

ARTEMIS (Automatic and Real-Time dEtection and MItigation System) is an open-source BGP hijacking detection tool developed by FORTH-ICS. This deployment integrates ARTEMIS into the Nuclear Lighters Kubernetes infrastructure via ArgoCD.

## Features

- Real-time BGP hijack detection via RIPE RIS Live and RouteViews
- Web-based UI for monitoring and configuration
- RPKI validation support (optional)
- Grafana-compatible metrics
- Automatic alerting via Prometheus

## Prerequisites

1. **RPKI/ROA Configuration**: Ensure your ROA objects are registered (pending iFog response)
2. **ASN Assignment**: Your customer ASN from iFog must be confirmed
3. **Prefix Allocation**: Your IPv4/IPv6 prefix allocations must be confirmed
4. **OpenBao Secrets**: Create the required secrets in OpenBao

## Deployment Steps

### 1. Create Secrets in OpenBao

Before deploying, create the ARTEMIS secrets in OpenBao:

```bash
# Connect to OpenBao
export VAULT_ADDR="http://10.0.X.X:8200"
vault login

# Create ARTEMIS secrets
vault kv put secret/artemis \
  db_pass="$(openssl rand -base64 32)" \
  admin_pass="$(openssl rand -base64 16)" \
  mongodb_pass="$(openssl rand -base64 32)" \
  rabbitmq_pass="$(openssl rand -base64 32)" \
  hasura_secret="$(openssl rand -base64 64)" \
  jwt_secret="$(openssl rand -base64 64)" \
  csrf_secret="$(openssl rand -base64 32)" \
  api_key="$(openssl rand -base64 32)" \
  captcha_secret="$(openssl rand -base64 32)"
```

### 2. Update Configuration

Edit `configmap.yaml` and `values.yaml` with your actual network details:

- Replace `YOUR_ASN_NUMBER` with your iFog-assigned ASN
- Replace `YOUR_IPV4_PREFIX/24` with your IPv4 prefix
- Replace `YOUR_IPV6_PREFIX/48` with your IPv6 prefix

### 3. Copy Files to GitLab Repository

```bash
# Copy the deployment files to your repository
cp -r k8s/argocd-apps/artemis ~/gitlab/infrastructure/nl/production/k8s/argocd-apps/

# Structure should be:
# k8s/argocd-apps/artemis/
# ├── application.yaml
# ├── configmap.yaml
# ├── external-secret.yaml
# ├── namespace.yaml
# ├── network-policy.yaml
# ├── service-monitor.yaml
# └── values.yaml
```

### 4. Commit and Push

```bash
cd ~/gitlab/infrastructure/nl/production
git add k8s/argocd-apps/artemis/
git commit -m "feat: add ARTEMIS BGP hijack detection deployment"
git push origin main
```

### 5. Register Application in ArgoCD

Either apply the application manifest directly or add it to your App of Apps:

```bash
kubectl apply -f k8s/argocd-apps/artemis/application.yaml
```

## Configuration

### ARTEMIS Configuration (configmap.yaml)

The ARTEMIS configuration defines:

- **Prefixes**: The IP prefixes your ASN originates
- **ASNs**: Your ASN and any transit/peer ASNs
- **Monitors**: Which BGP collectors to use (RIPE RIS, RouteViews)
- **Rules**: Expected routing policies

### Monitors Used

By default, this deployment uses:

| Monitor | Description |
|---------|-------------|
| rrc00 | RIPE RIS - Amsterdam |
| rrc03 | RIPE RIS - Amsterdam-IX |
| rrc12 | RIPE RIS - Frankfurt |
| rrc21 | RIPE RIS - Paris |
| rrc25 | RIPE RIS - Amsterdam |
| RouteViews | University of Oregon RouteViews project |

##***REMOVED***

- PostgreSQL: 10Gi (TimescaleDB for time-series data)
- MongoDB: Stores user data and session information
- Storage class: `nfs-client`

## Accessing ARTEMIS

After deployment, ARTEMIS will be available at:

- **URL**: https://artemis.example.net
- **Default admin**: admin@example.net (password in OpenBao)

## Monitoring

### Grafana Dashboard

ARTEMIS provides metrics compatible with Grafana. The ServiceMonitor will automatically scrape metrics.

### Prometheus Alerts

The following alerts are configured:

| Alert | Severity | Description |
|-------|----------|-------------|
| ARTEMISBGPHijackDetected | Critical | BGP hijack event detected |
| ARTEMISServiceDown | Warning | ARTEMIS service unreachable |
| ARTEMISNoBGPUpdates | Warning | No BGP updates for 30+ minutes |
| ARTEMISDatabaseStorageHigh | Warning | Database storage >80% |
| ARTEMISPodRestarting | Warning | Pod restarted >3 times/hour |

## Network Policy

The Cilium network policy restricts traffic to:

- Ingress: Only from nginx-ingress and internal services
- Egress: DNS, internal services, RIPE RIS Live, RouteViews, CAIDA

## Troubleshooting

### Check Pod Status

```bash
kubectl get pods -n artemis
kubectl logs -n artemis -l app.kubernetes.io/instance=artemis --all-containers
```

### Check BGP Monitor Connectivity

```bash
kubectl exec -n artemis deployment/artemis-monitor -- curl -s https://ris-live.ripe.net/
```

### Verify External Secret

```bash
kubectl get externalsecret -n artemis
kubectl describe externalsecret artemis-secrets -n artemis
```

### Check Helm Release

```bash
helm list -n artemis
helm status artemis -n artemis
```

## Resources

- [ARTEMIS Documentation](https://bgpartemis.readthedocs.io/)
- [ARTEMIS GitHub](https://github.com/FORTH-ICS-INSPIRE/artemis)
- [ARTEMIS Demo](https://demo.bgpartemis.org/)
- [RIPE RIS Live](https://ris-live.ripe.net/)

## Architecture

```
                    ┌─────────────────────────────────────────────────────────┐
                    │                    ARTEMIS Namespace                     │
                    │                                                          │
 ┌──────────┐       │  ┌──────────┐   ┌──────────┐   ┌──────────────────────┐ │
 │  RIPE    │◄──────┼──┤ Monitor  │──►│Detection │──►│     PostgreSQL       │ │
 │ RIS Live │       │  │ Services │   │ Service  │   │    (TimescaleDB)     │ │
 └──────────┘       │  └──────────┘   └──────────┘   └──────────────────────┘ │
                    │        │              │                    ▲             │
 ┌──────────┐       │        │              │                    │             │
 │RouteViews│◄──────┼────────┘              │                    │             │
 └──────────┘       │                       ▼                    │             │
                    │              ┌──────────────┐               │             │
                    │              │   RabbitMQ   │───────────────┤             │
                    │              │ Message Bus  │               │             │
                    │              └──────────────┘               │             │
                    │                       │                     │             │
                    │                       ▼                     │             │
                    │              ┌──────────────┐               │             │
 ┌──────────┐       │              │   Frontend   │◄──────────────┘             │
 │  Ingress │◄──────┼──────────────│   (Web UI)   │                             │
 │  NGINX   │       │              └──────────────┘                             │
 └──────────┘       │                       │                                   │
      │             │              ┌──────────────┐                             │
      │             │              │    Hasura    │                             │
      │             │              │   GraphQL    │                             │
      │             │              └──────────────┘                             │
      │             └─────────────────────────────────────────────────────────┘
      │
      ▼
┌───────────────────┐
│ artemis.          │
│ nuclearlighters.  │
│ net               │
└───────────────────┘
```

## License

ARTEMIS is licensed under BSD-3. See [LICENSE](https://github.com/FORTH-ICS-INSPIRE/artemis/blob/master/LICENSE).
