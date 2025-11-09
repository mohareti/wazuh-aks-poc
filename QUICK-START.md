# Wazuh on AKS POV - Quick Start Guide

## Deploy Wazuh in 3 Steps (10-15 minutes)

### Step 1: Prerequisites

```bash
# Install required tools
brew install azure-cli kubectl kustomize  # macOS
# OR
sudo apt-get install azure-cli kubectl kustomize  # Linux
# OR
choco install azure-cli kubernetes-cli kustomize  # Windows

# Verify installation
az --version && kubectl version --client && kustomize version
```

### Step 2: Clone and Deploy

```bash
# Clone the repository
git clone https://github.com/mohareti/wazuh-aks-poc.git
cd wazuh-aks-poc

# Set Azure configuration (optional - use defaults if not set)
export RESOURCE_GROUP="wazuh-rg"
export CLUSTER_NAME="wazuh-poc"
export LOCATION="eastus"

# Deploy everything
bash scripts/deploy-aks.sh
```

**What this does:**
- Creates Azure Resource Group
- Creates 3-node AKS cluster (B2s VMs - low cost)
- Deploys Wazuh Manager (Master + 2 Workers)
- Deploys Opensearch Indexer (3 nodes)
- Deploys Wazuh Dashboard
- Sets up persistent storage

### Step 3: Access Wazuh Dashboard

```bash
# Port forward to local machine
kubectl port-forward -n wazuh svc/wazuh-dashboard 5601:5601

# Open in browser
# https://localhost:5601

# Default Login:
# Username: admin
# Password: SecurePassword123!
```

---

## Verify Deployment

```bash
# Check pods
kubectl get pods -n wazuh

# Check services
kubectl get svc -n wazuh

# Check persistent volumes
kubectl get pvc -n wazuh

# View logs
kubectl logs -f <pod-name> -n wazuh
```

---

## Cost Estimate

```
3 × B2s nodes (3 months): ~$108
Storage (StandardSSD):     ~$36
Total: ~$144 for 3 months POV
```

---

## Cleanup (Delete Everything)

```bash
# This removes all resources and stops charges
bash scripts/cleanup-aks.sh

# When prompted, type 'yes' to confirm
```

---

## Common Commands

| Task | Command |
|------|----------|
| Dashboard Access | `kubectl port-forward svc/wazuh-dashboard 5601:5601 -n wazuh` |
| View Pods | `kubectl get pods -n wazuh` |
| Pod Logs | `kubectl logs -f <pod-name> -n wazuh` |
| Describe Pod | `kubectl describe pod <pod-name> -n wazuh` |
| Scale Workers | `kubectl scale statefulset wazuh-worker -n wazuh --replicas=3` |
| Check Storage | `kubectl get pvc -n wazuh` |
| Shell Into Pod | `kubectl exec -it <pod-name> -n wazuh -- bash` |
| Delete Pod | `kubectl delete pod <pod-name> -n wazuh` |

---

## Troubleshooting

### Pods Stuck in Pending
```bash
kubectl describe node
kubectl top nodes
```

### Can't Connect to Dashboard
```bash
# Make sure port-forward is running
kubectl port-forward svc/wazuh-dashboard 5601:5601 -n wazuh &

# Try HTTPS instead of HTTP
https://localhost:5601
```

### High Costs?
```bash
# Delete unused pods to save money
bash scripts/cleanup-aks.sh
```

### Need Help?
See full documentation in [README.md](README.md)

---

## Security Notes

⚠️ **This is for POV only - NOT production ready**

1. Change default passwords immediately
2. Use TLS/SSL for external access
3. Implement network policies
4. Use Azure Managed Identity
5. Enable audit logging

---

**Total Deployment Time**: ~15 minutes  
**Cost**: ~$100-150/month  
**Cleanup Time**: ~20 minutes
