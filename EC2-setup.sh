#!/usr/bin/env bash

#Creates a key pair used to connect to the instance
aws ec2 create-key-pair \
    --key-name MinecraftKeyPair \
    --key-type rsa \
    --output text \
    --query "KeyMaterial" \
    >> MinecraftKeyPair.pem

#Creates a minecraft security group
aws ec2 create-security-group \
    --description "Default security group for employee minecraft server" \
    --group-name "Minecraft Security Group"

# Modifies minecraft security group rules to allows anyone to connect via SSH
aws ec2 authorize-security-group-ingress \
    --group-name "Minecraft Security Group" \
    --protocol "tcp" \
    --cidr "0.0.0.0/0" \
    --port 22 

# Modifies minecraft security group rules to allows anyone to connect to the server
aws ec2 authorize-security-group-ingress \
    --group-name "Minecraft Security Group" \
    --protocol "tcp" \
    --cidr "0.0.0.0/0" \
    --port 25565

# Creates the EC2 instance we are running the server on

INSTANCE_ID=$(aws ec2 run-instances \
    --tag-specifications 'ResourceType=instance, Tags=[{Key=Name, Value=Minecraft Server Instance}]' \
    --instance-type "t4g.small" \
    --image-id "ami-0faea24786f93f390" \
    --key-name "MinecraftKeyPair" \
    --security-groups "Minecraft Security Group" \
    --block-device-mappings '[{"DeviceName":"/dev/sdg", "Ebs":{"VolumeSize": 8}}]' \
    --output text \
    --query "Instances[0].InstanceId")
    # --associate-public-ip-address \
echo "Instance Generated With Instance ID: $INSTANCE_ID"

INSTANCE_IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --output text \
    --query "Reservations[-1].Instances[-1].PublicIpAddress")
echo "Instance Generated With Instance IP: $INSTANCE_IP"

ssh -o StrictHostKeyChecking=accept-new -i MinecraftKeyPair.pem ec2-user@$INSTANCE_IP whoami