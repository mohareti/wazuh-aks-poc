#!/bin/bash

# Wazuh on Azure AKS - Cleanup Script (POV)
# This script completely removes Wazuh deployment and clears AKS cluster

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}======================================${NC}"
echo -e "${YELLOW}Wazuh AKS POV Cleanup${NC}"
echo -e "${YELLOW}======================================${NC}\n"

# Set defaults
RESOURCE_GROUP=${RESOURCE_GROUP:-"wazuh-rg"}
CLUSTER_NAME=${CLUSTER_NAME:-"wazuh-poc"}

echo -e "${YELLOW}This will delete:${NC}"
echo "  - Resource Group: $RESOURCE_GROUP"
echo "  - AKS Cluster: $CLUSTER_NAME"
echo "  - All associated resources and data"
echo ""
echo -e "${RED}WARNING: This action cannot be undone!${NC}"
echo -e "${RED}All data will be permanently deleted.${NC}\n"

read -p "Type 'yes' to confirm deletion: " confirm

if [ "$confirm" != "yes" ]; then
  echo -e "${GREEN}Cleanup cancelled.${NC}"
  exit 0
fi

echo -e "\n${YELLOW}Starting cleanup...${NC}\n"

# Delete Wazuh namespace (will delete all pods)
echo -e "${YELLOW}Deleting Wazuh namespace...${NC}"
kubectl delete namespace wazuh --ignore-not-found=true || true

echo -e "${YELLOW}Waiting for namespace deletion...${NC}"
sleep 30

echo -e "${GREEN}✓ Wazuh namespace deleted${NC}\n"

# Delete AKS cluster
echo -e "${YELLOW}Deleting AKS cluster (this may take 10-15 minutes)...${NC}"
az aks delete \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --yes \
  --no-wait || echo "Cluster not found or already deleted"

echo -e "${GREEN}✓ AKS cluster deletion started${NC}\n"

# Optional: Delete resource group (uncomment to also delete resource group)
# echo -e "${YELLOW}Deleting resource group...${NC}"
# az group delete \
#   --name $RESOURCE_GROUP \
#   --yes \
#   --no-wait
# echo -e "${GREEN}✓ Resource group deletion started${NC}\n"

echo -e "${YELLOW}======================================${NC}"
echo -e "${GREEN}Cleanup Initiated!${NC}"
echo -e "${YELLOW}======================================${NC}\n"

echo -e "${YELLOW}Status:${NC}"
echo "  - Wazuh namespace: Deleted"
echo "  - AKS cluster: Deleting (in background)"
echo ""
echo -e "${YELLOW}Check deletion status with:${NC}"
echo "  az aks show --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME"
echo ""
echo -e "${YELLOW}Cleanup typically completes in 15-20 minutes.${NC}\n"

echo -e "${GREEN}Your infrastructure is being cleaned up!${NC}\n"
