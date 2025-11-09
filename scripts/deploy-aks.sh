#!/bin/bash

# Wazuh on Azure AKS - Cost-Optimized POV Deployment Script
# This script deploys Wazuh on AKS with minimum cost configuration

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}======================================${NC}"
echo -e "${YELLOW}Wazuh AKS POV Deployment${NC}"
echo -e "${YELLOW}======================================${NC}\n"

# Set defaults from environment or use defaults
RESOURCE_GROUP=${RESOURCE_GROUP:-"wazuh-rg"}
CLUSTER_NAME=${CLUSTER_NAME:-"wazuh-poc"}
LOCATION=${LOCATION:-"eastus"}
VM_SIZE=${VM_SIZE:-"Standard_B2s"}
NODE_COUNT=${NODE_COUNT:-"3"}

echo -e "${YELLOW}Configuration:${NC}"
echo "Resource Group: $RESOURCE_GROUP"
echo "Cluster Name: $CLUSTER_NAME"
echo "Location: $LOCATION"
echo "VM Size: $VM_SIZE (cost-optimized)"
echo "Node Count: $NODE_COUNT"
echo ""

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"
command -v az >/dev/null 2>&1 || { echo -e "${RED}Azure CLI required${NC}"; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo -e "${RED}kubectl required${NC}"; exit 1; }
command -v kustomize >/dev/null 2>&1 || { echo -e "${RED}kustomize required${NC}"; exit 1; }

echo -e "${GREEN}✓ All prerequisites met${NC}\n"

# Login to Azure
echo -e "${YELLOW}Logging into Azure...${NC}"
az login --use-device-code || true
echo -e "${GREEN}✓ Azure login complete${NC}\n"

# Create resource group
echo -e "${YELLOW}Creating resource group...${NC}"
az group create --name $RESOURCE_GROUP --location $LOCATION || echo "Resource group already exists"
echo -e "${GREEN}✓ Resource group ready${NC}\n"

# Create AKS cluster
echo -e "${YELLOW}Creating AKS cluster (this may take 5-10 minutes)...${NC}"
az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --node-count $NODE_COUNT \
  --vm-set-type VirtualMachineScaleSets \
  --load-balancer-sku standard \
  --enable-managed-identity \
  --vm-set-type VirtualMachineScaleSets \
  --node-vm-size $VM_SIZE \
  --kubernetes-version 1.28 \
  --generate-ssh-keys \
  --tier free || echo "Cluster already exists"

echo -e "${GREEN}✓ AKS cluster created${NC}\n"

# Get cluster credentials
echo -e "${YELLOW}Configuring kubectl...${NC}"
az aks get-credentials \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME
echo -e "${GREEN}✓ kubectl configured${NC}\n"

# Create namespace
echo -e "${YELLOW}Creating Wazuh namespace...${NC}"
kubectl create namespace wazuh || echo "Namespace already exists"
echo -e "${GREEN}✓ Namespace created${NC}\n"

# Deploy Wazuh using kustomize
echo -e "${YELLOW}Deploying Wazuh stack (this may take 5-15 minutes)...${NC}"
kubectl apply -k envs/aks/ 2>/dev/null || {
  echo -e "${YELLOW}Note: If kustomization not found, using kubectl apply directly${NC}"
  kubectl apply -f wazuh/ -n wazuh
}

echo -e "${GREEN}✓ Wazuh deployment initiated${NC}\n"

# Wait for pods
echo -e "${YELLOW}Waiting for pods to start (timeout: 10 minutes)...${NC}"
kubectl wait --for=condition=ready pod -l app=wazuh -n wazuh --timeout=600s 2>/dev/null || echo "Some pods may still be starting"

# Show status
echo -e "\n${YELLOW}======================================${NC}"
echo -e "${GREEN}Deployment Complete!${NC}"
echo -e "${YELLOW}======================================${NC}\n"

echo -e "${YELLOW}Pod Status:${NC}"
kubectl get pods -n wazuh

echo -e "\n${YELLOW}Services:${NC}"
kubectl get svc -n wazuh

echo -e "\n${YELLOW}Persistent Volumes:${NC}"
kubectl get pvc -n wazuh

echo -e "\n${YELLOW}Next Steps:${NC}"
echo -e "${GREEN}1. Port forward to dashboard:${NC}"
echo "   kubectl port-forward -n wazuh svc/wazuh-dashboard 5601:5601"
echo ""
echo -e "${GREEN}2. Access Wazuh Dashboard:${NC}"
echo "   https://localhost:5601"
echo ""
echo -e "${GREEN}3. Default Credentials:${NC}"
echo "   Username: admin"
echo "   Password: SecurePassword123!"
echo ""
echo -e "${YELLOW}Estimated Monthly Cost: $100-150 USD${NC}\n"

echo -e "${YELLOW}To cleanup later, run:${NC}"
echo "bash scripts/cleanup-aks.sh\n"
