# #!/bin/bash

# # Create RabbitMQ namespace
# echo "Creating RabbitMQ namespace..."
# kubectl apply -f 01-rabbitmq-namespace.yaml

# # Create RabbitMQ secrets
# echo "Creating RabbitMQ secrets..."
# kubectl apply -f 02-rabbitmq-secrets.yaml

# # Create RabbitMQ ConfigMap
# echo "Creating RabbitMQ ConfigMap..."
# kubectl apply -f 03-rabbitmq-configmap.yaml

# # Set up RBAC for RabbitMQ
# echo "Setting up RBAC for RabbitMQ..."
# kubectl apply -f 04-rabbitmq-rbac.yaml

# # Create Storage Resources
# echo "Creating Storage Resources..."
# kubectl apply -f 05-rabbitmq-storage.yaml

# # Deploy RabbitMQ StatefulSet
# echo "Deploying RabbitMQ StatefulSet..."
# kubectl apply -f 06-rabbitmq-statefulset.yaml

# # Create RabbitMQ Services
# echo "Creating RabbitMQ Services..."
# kubectl apply -f 07-rabbitmq-services.yaml

# # Create RabbitMQ Ingress (optional)
# echo "Creating RabbitMQ Ingress..."
# kubectl apply -f 08-rabbitmq-ingress.yaml

# # Create Monitoring Resources (optional)
# echo "Creating Monitoring Resources..."
# kubectl apply -f 09-rabbitmq-monitoring.yaml

# # Wait for RabbitMQ to be ready
# echo "Waiting for RabbitMQ pods to be ready..."
# kubectl wait --for=condition=ready pod/rabbitmq-0 -n rabbitmq-system --timeout=300s
# kubectl wait --for=condition=ready pod/rabbitmq-1 -n rabbitmq-system --timeout=300s
# kubectl wait --for=condition=ready pod/rabbitmq-2 -n rabbitmq-system --timeout=300s

# # Display connection information
# echo "==========================="
# echo "RabbitMQ deployment complete!"
# echo "==========================="
# echo "For GraphQL services, use the following connection settings:"
# echo "Host: rabbitmq.rabbitmq-system.svc.cluster.local"
# echo "Port: 5672"
# echo "User: admin (from secret rabbitmq-secrets)"
# echo "Password: changeme123 (from secret rabbitmq-secrets)"
# echo "==========================="
# echo "Management UI is available at:"
# echo "http://rabbitmq.example.com or http://NODE_IP:31672"
# echo "==========================="
# echo "Pre-configured resources for GraphQL services:"
# echo "- Exchange: graphql-events (topic)"
# echo "- Exchange: graphql-commands (direct)"
# echo "- Queues: service1-events through service6-events"
# echo "- Dead letter queue: graphql-dead-letter"
# echo "==========================="

#!/bin/bash

# Set variables
NAMESPACE="rabbitmq-system"

# Function to check if command succeeded
check_success() {
  if [ $? -ne 0 ]; then
    echo "ERROR: $1 failed"
    exit 1
  fi
}

# Delete any existing resources that might be causing issues
echo "Cleaning up any existing resources..."
kubectl delete statefulset rabbitmq -n $NAMESPACE --ignore-not-found=true
kubectl delete pvc data-rabbitmq-0 -n $NAMESPACE --ignore-not-found=true
kubectl delete pv rabbitmq-pv-0 --ignore-not-found=true

# Create namespace if it doesn't exist
echo "Creating namespace..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
check_success "Create namespace"

# Check storage classes available
echo "Available storage classes:"
kubectl get storageclass
echo ""

# Apply the configurations in order
echo "Creating secrets..."
kubectl apply -f 02-rabbitmq-secrets.yaml
check_success "Create secrets"

echo "Creating ConfigMap..."
kubectl apply -f 03-rabbitmq-configmap.yaml
check_success "Create ConfigMap"

echo "Setting up RBAC..."
kubectl apply -f 04-rabbitmq-rbac.yaml
check_success "Set up RBAC"

echo "Creating storage resources..."
kubectl apply -f 05-rabbitmq-storage.yaml
check_success "Create storage"

# Wait for PV to be available
echo "Waiting for PV to be available..."
sleep 5
kubectl get pv

# Create StatefulSet
echo "Creating StatefulSet..."
kubectl apply -f 06-rabbitmq-statefulset.yaml
check_success "Create StatefulSet"

# Create services
echo "Creating services..."
kubectl apply -f 07-rabbitmq-services.yaml
check_success "Create services"

# Monitor pod creation
echo "Monitoring pod creation (press Ctrl+C to stop watching)..."
kubectl get pods -n $NAMESPACE -w

# Display connection info
echo "==========================="
echo "RabbitMQ deployment script completed!"
echo "Check pod status with: kubectl get pods -n $NAMESPACE"
echo "Check PVC status with: kubectl get pvc -n $NAMESPACE"
echo "Check pod events with: kubectl describe pod <pod-name> -n $NAMESPACE"
echo "==========================="