# Wazuh on Azure AKS - Cost Optimized POV

## Overview

This repository contains a **production-ready, cost-optimized** deployment of Wazuh on Azure Kubernetes Service (AKS) specifically designed for Proof of Concept (POV) environments.

### Key Features

- ✅ **Cost Optimized**: Uses minimum pricing Azure components (~$250-300/month)
- ✅ **Fast Deployment**: Single-command setup and teardown
- ✅ **Automated Scripts**: Deploy, monitor, and cleanup with bash scripts
- ✅ **Security Monitoring**: Full Wazuh stack with indexer, dashboard, and managers
- ✅ **Production Ready**: Best practices for AKS deployment
- ✅ **Free Tier Compatible**: Works with Azure Free Tier

## Cost Breakdown (Monthly Estimate)

```
AKS Control Plane (Free):            $0.00
Compute (3 × B2s nodes):            $90.00
Storage (StandardSSD, 85GB total):  $12.00
Bandwidth (Internal):                $0.00
-------------------------------------------
TOTAL:                             $102.00/month
```

> **Cost Comparison**: Save 70-80% vs. Standard setups!

## Quick Start (5 Minutes)

### Prerequisites

```bash
# Install required tools
# Azure CLI: https://docs.microsoft.com/cli/azure
# kubectl: https://kubernetes.io/docs/tasks/tools/
# kustomize: https://kubernetes-sigs.github.io/kustomize/

# Verify installations
az --version
kubectl version --client
kustomize version
```

### One-Command Deployment

```bash
# 1. Clone this repository
git clone https://github.com/mohareti/wazuh-aks-poc.git
cd wazuh-aks-poc

# 2. Set your Azure details
export RESOURCE_GROUP="wazuh-rg"
export CLUSTER_NAME="wazuh-poc"
export LOCATION="eastus"  # Choose your region

# 3. Run deployment script
bash scripts/deploy-aks.sh

# Wait ~5-10 minutes for pods to start
```

### Access Wazuh Dashboard

```bash
# Port forward to dashboard
kubectl port-forward -n wazuh svc/wazuh-dashboard 5601:5601 &

# Open in browser
# https://localhost:5601

# Default credentials
# Username: admin
# Password: SecurePassword123!  (CHANGE THIS!)
```

## One-Command Cleanup

```bash
# Delete everything and free up Azure resources
bash scripts/cleanup-aks.sh
```

## Detailed Documentation

- 📖 [Full Deployment Guide](docs/DEPLOYMENT-GUIDE.md)
- 💰 [Detailed Cost Analysis](docs/COST-ANALYSIS.md)
- 🔧 [Troubleshooting Guide](docs/TROUBLESHOOTING.md)
- 🏗️ [Architecture Overview](docs/ARCHITECTURE.md)

## Directory Structure

```
.
├── README.md
├── scripts/
│   ├── deploy-aks.sh          # Deploy Wazuh on AKS
│   ├── cleanup-aks.sh         # Delete cluster & resources
│   ├── generate-certs.sh      # Generate TLS certificates
│   └── validate-deployment.sh # Verify deployment status
├── envs/
│   └── aks/                   # AKS-specific configurations
│       ├── kustomization.yml
│       ├── storage-class.yaml
│       └── patches/
├── wazuh/                     # Base Wazuh configurations
│   ├── base/
│   ├── wazuh_managers/
│   ├── indexer_stack/
│   ├── certs/
│   └── secrets/
└── docs/
    ├── DEPLOYMENT-GUIDE.md
    ├── COST-ANALYSIS.md
    ├── TROUBLESHOOTING.md
    └── ARCHITECTURE.md
```

## What's Included

### Kubernetes Resources
- **Wazuh Manager**: Master + 2 Worker nodes
- **Opensearch Indexer**: 3-node cluster for log storage
- **Wazuh Dashboard**: Web UI for visualization
- **Persistent Storage**: Azure Managed Disks
- **Networking**: Kubernetes Services with internal LB

### Optimizations
- **B-Series VMs**: Burst-capable, cost-efficient compute
- **StandardSSD Disks**: Balanced performance & cost
- **Resource Quotas**: Prevents overspending
- **Auto-scaling**: Disabled by default for cost control

## Cost Comparison

| Component | Standard | POV (This Repo) | Savings |
|-----------|----------|-----------------|----------|
| Compute | $420/mo | $90/mo | 79% |
| Storage | $50/mo | $12/mo | 76% |
| Total | $550/mo | $102/mo | 81% |

## Common Tasks

### View Pod Status
```bash
kubectl get pods -n wazuh
kubectl describe pod <pod-name> -n wazuh
```

### Check Logs
```bash
kubectl logs <pod-name> -n wazuh
kubectl logs -f <pod-name> -n wazuh  # Follow logs
```

### Scale Wazuh Workers
```bash
kubectl scale statefulset wazuh-worker -n wazuh --replicas=3
```

### Check Storage Usage
```bash
kubectl get pvc -n wazuh
kubectl exec -it wazuh-indexer-0 -n wazuh -- df -h
```

### Restart Pods
```bash
kubectl delete pod <pod-name> -n wazuh
```

## Security Notes

⚠️ **IMPORTANT**: This is for POV/testing only. For production:

1. **Change Default Passwords**
   ```bash
   kubectl exec -it wazuh-master-0 -n wazuh -- bash
   /opt/wazuh/bin/wazuh-control start
   ```

2. **Enable TLS for External Access**
   - Use Azure Application Gateway
   - Enable ingress with SSL certificates

3. **Implement Network Policies**
   - Restrict pod-to-pod communication
   - Use Azure Network Policies

4. **Backup Important Data**
   - Configure Azure Backup
   - Export encryption keys

## Troubleshooting

### Pods Stuck in Pending
```bash
kubectl describe node
kubectl top nodes
```

### High Storage Usage
```bash
# Check indexer data
kubectl exec -it wazuh-indexer-0 -n wazuh -- du -sh /data

# Implement index lifecycle management
# See docs/TROUBLESHOOTING.md
```

### Connection Refused
```bash
kubectl port-forward svc/wazuh-dashboard 5601:5601 -n wazuh
```

## Architecture

```
┌─────────────────────────────────────────────┐
│           Azure AKS Cluster                 │
├─────────────────────────────────────────────┤
│                                             │
│  ┌──────────────────┐  ┌──────────────┐   │
│  │ Wazuh Manager    │  │ Indexer      │   │
│  │ (Master + 2 WKR) │  │ (3 nodes)    │   │
│  └──────────────────┘  └──────────────┘   │
│                                             │
│  ┌──────────────────────────────────────┐  │
│  │        Wazuh Dashboard               │  │
│  │  (Web UI - https://localhost:5601)   │  │
│  └──────────────────────────────────────┘  │
│                                             │
│  ┌──────────────────────────────────────┐  │
│  │    Persistent Storage (50GB)         │  │
│  │   (Azure StandardSSD Managed Disk)   │  │
│  └──────────────────────────────────────┘  │
│                                             │
└─────────────────────────────────────────────┘
```

## Support

- 📚 [Wazuh Official Docs](https://documentation.wazuh.com/)
- 🐛 [Report Issues](https://github.com/mohareti/wazuh-aks-poc/issues)
- 💬 [GitHub Discussions](https://github.com/mohareti/wazuh-aks-poc/discussions)

## License

This project is licensed under GPL-2.0 (same as Wazuh)

## Disclaimer

⚠️ This is a POV/testing solution. Use with caution in production environments. Always:
- Test thoroughly before production use
- Follow security best practices
- Monitor costs carefully
- Implement proper backups
- Use strong, unique passwords

## Quick Reference

| Task | Command |
|------|----------|
| Deploy | `bash scripts/deploy-aks.sh` |
| Cleanup | `bash scripts/cleanup-aks.sh` |
| Dashboard | `kubectl port-forward svc/wazuh-dashboard 5601:5601 -n wazuh` |
| Pod Status | `kubectl get pods -n wazuh` |
| Logs | `kubectl logs -f <pod-name> -n wazuh` |
| Check Costs | See [COST-ANALYSIS.md](docs/COST-ANALYSIS.md) |

---

**Created**: November 2025  
**Optimized for**: Azure AKS POV  
**Cost Target**: <$300/month  
**Deployment Time**: ~10 minutes
