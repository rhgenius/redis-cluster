#!/bin/bash
set -e

# Update and install dependencies
sudo apt-get update
sudo apt-get install -y redis-server

# Stop default Redis service
sudo systemctl stop redis-server

# Create directories for two Redis instances
sudo mkdir -p /etc/redis/7005 /etc/redis/7006
sudo mkdir -p /var/lib/redis/7005 /var/lib/redis/7006
sudo chown -R redis:redis /var/lib/redis

# Copy default config and modify for cluster
sudo cp /etc/redis/redis.conf /etc/redis/7005/redis.conf
sudo cp /etc/redis/redis.conf /etc/redis/7006/redis.conf

# Configure instance 7005
sudo sed -i 's/^port .*/port 7005/' /etc/redis/7005/redis.conf
sudo sed -i 's/^dir .*/dir \/var\/lib\/redis\/7005\//' /etc/redis/7005/redis.conf
sudo sed -i 's/^# cluster-enabled yes/cluster-enabled yes/' /etc/redis/7005/redis.conf
sudo sed -i 's/^# cluster-config-file nodes-7005.conf/cluster-config-file nodes-7005.conf/' /etc/redis/7005/redis.conf
sudo sed -i 's/^# cluster-node-timeout 15000/cluster-node-timeout 5000/' /etc/redis/7005/redis.conf
sudo sed -i 's/^bind .*/bind 0.0.0.0/' /etc/redis/7005/redis.conf
sudo sed -i 's/^protected-mode yes/protected-mode no/' /etc/redis/7005/redis.conf
echo "daemonize yes" | sudo tee -a /etc/redis/7005/redis.conf

# Configure instance 7006
sudo sed -i 's/^port .*/port 7006/' /etc/redis/7006/redis.conf
sudo sed -i 's/^dir .*/dir \/var\/lib\/redis\/7006\//' /etc/redis/7006/redis.conf
sudo sed -i 's/^# cluster-enabled yes/cluster-enabled yes/' /etc/redis/7006/redis.conf
sudo sed -i 's/^# cluster-config-file nodes-7006.conf/cluster-config-file nodes-7006.conf/' /etc/redis/7006/redis.conf
sudo sed -i 's/^# cluster-node-timeout 15000/cluster-node-timeout 5000/' /etc/redis/7006/redis.conf
sudo sed -i 's/^bind .*/bind 0.0.0.0/' /etc/redis/7006/redis.conf
sudo sed -i 's/^protected-mode yes/protected-mode no/' /etc/redis/7006/redis.conf
echo "daemonize yes" | sudo tee -a /etc/redis/7006/redis.conf

# Start both Redis instances
sudo redis-server /etc/redis/7005/redis.conf
sudo redis-server /etc/redis/7006/redis.conf

echo "Redis instances on ports 7005 and 7006 started."
echo "Repeat similar setup on node1 and node2 with ports 7001/7002 and 7003/7004 respectively."
echo "After all nodes are up, create the cluster from one node:"
echo "redis-cli --cluster create <node1_ip>:7001 <node1_ip>:7002 <node2_ip>:7003 <node2_ip>:7004 <node3_ip>:7005 <node3_ip>:7006 --cluster-replicas 1"