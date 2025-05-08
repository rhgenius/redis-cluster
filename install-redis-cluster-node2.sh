#!/bin/bash
set -e

# Update and install dependencies
sudo apt-get update
sudo apt-get install -y redis-server

# Stop default Redis service
sudo systemctl stop redis-server

# Create directories for two Redis instances
sudo mkdir -p /etc/redis/7003 /etc/redis/7004
sudo mkdir -p /var/lib/redis/7003 /var/lib/redis/7004
sudo chown -R redis:redis /var/lib/redis

# Copy default config and modify for cluster
sudo cp /etc/redis/redis.conf /etc/redis/7003/redis.conf
sudo cp /etc/redis/redis.conf /etc/redis/7004/redis.conf

# Configure instance 7003
sudo sed -i 's/^port .*/port 7003/' /etc/redis/7003/redis.conf
sudo sed -i 's/^dir .*/dir \/var\/lib\/redis\/7003\//' /etc/redis/7003/redis.conf
sudo sed -i 's/^# cluster-enabled yes/cluster-enabled yes/' /etc/redis/7003/redis.conf
sudo sed -i 's/^# cluster-config-file nodes-7003.conf/cluster-config-file nodes-7003.conf/' /etc/redis/7003/redis.conf
sudo sed -i 's/^# cluster-node-timeout 15000/cluster-node-timeout 5000/' /etc/redis/7003/redis.conf
sudo sed -i 's/^bind .*/bind 0.0.0.0/' /etc/redis/7003/redis.conf
sudo sed -i 's/^protected-mode yes/protected-mode no/' /etc/redis/7003/redis.conf
echo "daemonize yes" | sudo tee -a /etc/redis/7003/redis.conf

# Configure instance 7004
sudo sed -i 's/^port .*/port 7004/' /etc/redis/7004/redis.conf
sudo sed -i 's/^dir .*/dir \/var\/lib\/redis\/7004\//' /etc/redis/7004/redis.conf
sudo sed -i 's/^# cluster-enabled yes/cluster-enabled yes/' /etc/redis/7004/redis.conf
sudo sed -i 's/^# cluster-config-file nodes-7004.conf/cluster-config-file nodes-7004.conf/' /etc/redis/7004/redis.conf
sudo sed -i 's/^# cluster-node-timeout 15000/cluster-node-timeout 5000/' /etc/redis/7004/redis.conf
sudo sed -i 's/^bind .*/bind 0.0.0.0/' /etc/redis/7004/redis.conf
sudo sed -i 's/^protected-mode yes/protected-mode no/' /etc/redis/7004/redis.conf
echo "daemonize yes" | sudo tee -a /etc/redis/7004/redis.conf

# Start both Redis instances
sudo redis-server /etc/redis/7003/redis.conf
sudo redis-server /etc/redis/7004/redis.conf

echo "Redis instances on ports 7003 and 7004 started."
echo "Repeat similar setup on node1 and node3 with ports 7001/7002 and 7005/7006 respectively."
echo "After all nodes are up, create the cluster from one node:"
echo "redis-cli --cluster create <node1_ip>:7001 <node1_ip>:7002 <node2_ip>:7003 <node2_ip>:7004 <node3_ip>:7005 <node3_ip>:7006 --cluster-replicas 1"