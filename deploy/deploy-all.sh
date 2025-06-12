#!/bin/bash
# Script para desplegar RabbitMQ en Kubernetes

echo "Desplegando RabbitMQ en Kubernetes..."

# Aplicar los manifiestos en orden
kubectl apply -f rabbitmq-configmap.yaml
if [ $? -ne 0 ]; then
    echo "Error al aplicar ConfigMap"
    exit 1
fi
echo "ConfigMap creado correctamente"

kubectl apply -f rabbitmq-deployment.yaml  # Cambiado de statefulset a deployment
if [ $? -ne 0 ]; then
    echo "Error al aplicar Deployment"
    exit 1
fi
echo "Deployment creado correctamente"

kubectl apply -f rabbitmq-service.yaml
if [ $? -ne 0 ]; then
    echo "Error al aplicar Service"
    exit 1
fi
echo "Service creado correctamente"

kubectl apply -f rabbitmq-nodeport.yaml
if [ $? -ne 0 ]; then
    echo "Error al aplicar NodePort Service"
    exit 1
fi
echo "NodePort Service creado correctamente"

# Esperar a que el pod esté listo
echo "Esperando a que RabbitMQ esté listo..."
kubectl wait --for=condition=ready pod -l app=rabbitmq --timeout=120s

echo ""
echo "Despliegue completado exitosamente!"
echo "Para acceder a RabbitMQ Management:"
echo "- URL: http://<IP-NODO>:30672"
echo "- Usuario: user"
echo "- Contraseña: password"
echo ""
echo "Para conectar tus aplicaciones:"
echo "- Dentro del cluster: rabbitmq.bi-system:5672"
echo "- Fuera del cluster: <IP-NODO>:30673"