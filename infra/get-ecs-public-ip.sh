#!/bin/bash

# Configurations
AWS_PROFILE="${1:-default}"
REGION="${2:-us-east-1}"


# Variables
CLUSTER_NAME="nims-tofu-cluster"
SERVICE_NAME="nims-tofu"

# Get the task ARN
TASK_ARN=$(aws ecs list-tasks \
  --cluster "$CLUSTER_NAME" \
  --service-name "$SERVICE_NAME" \
  --query "taskArns[0]" \
  --output text \
  --profile "$AWS_PROFILE" \
  --region "$REGION")

if [ "$TASK_ARN" == "None" ]; then
  echo "No running tasks found for the service."
  exit 1
fi

# Get the ENI ID from the task
ENI_ID=$(aws ecs describe-tasks \
  --cluster "$CLUSTER_NAME" \
  --tasks "$TASK_ARN" \
  --query "tasks[0].attachments[0].details[?name=='networkInterfaceId'].value" \
  --output text \
  --profile "$AWS_PROFILE" \
  --region "$REGION")

if [ -z "$ENI_ID" ]; then
  echo "No ENI found for the task."
  exit 1
fi

# Get the public IP from the ENI
PUBLIC_IP=$(aws ec2 describe-network-interfaces \
  --network-interface-ids "$ENI_ID" \
  --query "NetworkInterfaces[0].Association.PublicIp" \
  --output text \
  --profile "$AWS_PROFILE" \
  --region "$REGION")

if [ "$PUBLIC_IP" == "None" ]; then
  echo "No public IP assigned to the service."
else
  echo "Public IP of the ECS service: $PUBLIC_IP"
fi
