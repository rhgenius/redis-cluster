#!/bin/bash
set -e

# Please replace these with the actual private IP addresses of your nodes
NODE1_IP="<node1_ip>"
NODE2_IP="<node2_ip>"
NODE3_IP="<node3_ip>"

# Cluster ports for each node
PORTS=(
    "$NODE1_IP:7001"
    "$NODE1_IP:7002"
    "$NODE2_IP:7003"
    "$NODE2_IP:7004"
    "$NODE3_IP:7005"
    "$NODE3_IP:7006"
)

# Join all ports into a single string
CLUSTER_NODES="${PORTS[*]}"

# Create the cluster with 3 masters and 3 slaves
echo "Creating Redis cluster with nodes: $CLUSTER_NODES"
redis-cli --cluster create $CLUSTER_NODES --cluster-replicas 1

echo "Cluster configuration command executed. Please follow the prompts to confirm cluster creation."