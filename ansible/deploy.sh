#!/usr/bin/env bash
# =============================================================================
# deploy.sh - Despliega TODO de forma automatica: Terraform + Ansible
# =============================================================================
set -euo pipefail

# Desactiva la verificacion interactiva de host key SSH: en cada "apply" la VM
# es nueva (o tiene nueva IP), y no debe requerir confirmacion manual "yes/no".
export ANSIBLE_HOST_KEY_CHECKING=False

DIR_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIR_TERRAFORM="$DIR_SCRIPT/../terraform"

echo ">>> 1) Aplicando infraestructura con Terraform..."
terraform -chdir="$DIR_TERRAFORM" init -input=false
terraform -chdir="$DIR_TERRAFORM" apply -auto-approve

echo ">>> 2) Inventario y variables generados automaticamente por Terraform:"
echo "     - ansible/hosts"
echo "     - ansible/group_vars/all.yml"

echo ">>> 3) Instalando la coleccion de Ansible para Podman (si falta)..."
ansible-galaxy collection install containers.podman

echo ">>> 4) Esperando a que la VM responda por SSH..."
until ansible podman_vm -i "$DIR_SCRIPT/hosts" -m ping &>/dev/null; do
  echo "    ...VM todavia no responde, reintentando en 10s"
  sleep 10
done

echo ">>> 5) Ejecutando el playbook..."
ansible-playbook -i "$DIR_SCRIPT/hosts" "$DIR_SCRIPT/playbook.yml"

echo ">>> 6) Obteniendo credenciales del cluster AKS (kubeconfig)..."
NOMBRE_GRUPO=$(terraform -chdir="$DIR_TERRAFORM" output -raw nombre_grupo_recursos 2>/dev/null || echo "rg-casopractico2")
NOMBRE_AKS=$(terraform -chdir="$DIR_TERRAFORM" output -raw aks_nombre_cluster)
az aks get-credentials --resource-group "$NOMBRE_GRUPO" --name "$NOMBRE_AKS" --overwrite-existing

echo ">>> 7) Instalando la coleccion de Ansible para Kubernetes (si falta)..."
ansible-galaxy collection install kubernetes.core
python3 -m pip install --quiet --break-system-packages --ignore-installed PyYAML kubernetes

echo ">>> 8) Probando el pull del ACR en AKS (playbook_k8s.yml)..."
ansible-playbook "$DIR_SCRIPT/playbook_k8s.yml"

echo ">>> Despliegue completado (VM + AKS)."

IP=$(terraform -chdir="$DIR_TERRAFORM" output -raw ip_publica_vm)
echo ">>> Prueba la web con:"
echo "    curl -k -u alumno:unir2026 https://$IP/"
