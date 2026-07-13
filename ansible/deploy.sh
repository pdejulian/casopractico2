#!/usr/bin/env bash
# =============================================================================
# deploy.sh - Despliega TODO de forma automatica: Terraform + Ansible
# =============================================================================
set -euo pipefail

export ANSIBLE_HOST_KEY_CHECKING=False

DIR_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIR_TERRAFORM="$DIR_SCRIPT/../terraform"

echo ">>> 1) Aplicando infraestructura con Terraform (ACR + VM + AKS)..."
terraform -chdir="$DIR_TERRAFORM" init -input=false
terraform -chdir="$DIR_TERRAFORM" apply -auto-approve

echo ">>> 2) Inventario y variables generados automaticamente por Terraform."

echo ">>> 3) Instalando colecciones de Ansible necesarias (si faltan)..."
ansible-galaxy collection install containers.podman
ansible-galaxy collection install kubernetes.core
ansible-galaxy collection install community.docker
python3 -m pip install --quiet --break-system-packages --ignore-installed PyYAML kubernetes

echo ">>> 4) Esperando a que la VM responda por SSH..."
until ansible podman_vm -i "$DIR_SCRIPT/hosts" -m ping &>/dev/null; do
  echo "    ...VM todavia no responde, reintentando en 10s"
  sleep 10
done

echo ">>> 5) Desplegando el servidor web en Podman (VM)..."
ansible-playbook -i "$DIR_SCRIPT/hosts" "$DIR_SCRIPT/playbook.yml"

echo ">>> 6) Obteniendo credenciales del cluster AKS (kubeconfig)..."
NOMBRE_GRUPO=$(terraform -chdir="$DIR_TERRAFORM" output -raw nombre_grupo_recursos)
NOMBRE_AKS=$(terraform -chdir="$DIR_TERRAFORM" output -raw aks_nombre_cluster)
az aks get-credentials --resource-group "$NOMBRE_GRUPO" --name "$NOMBRE_AKS" --overwrite-existing


echo ">>> 7) Construyendo y subiendo la imagen del proxy TLS (Ansible + Podman)..."
ansible-playbook "$DIR_SCRIPT/playbook_imagen_proxy.yml"

echo ">>> 8) Desplegando WordPress + MySQL con persistencia en AKS..."
ansible-playbook "$DIR_SCRIPT/playbook_wordpress.yml"

echo ">>> Despliegue completado: VM (Podman) + AKS (WordPress persistente)."

IP=$(terraform -chdir="$DIR_TERRAFORM" output -raw ip_publica_vm)
echo ">>> Web de la VM (Podman):"
echo "    curl -k -u alumno:unir2026 https://$IP/"
echo ">>> WordPress (AKS): revisa la IP publica mostrada por el playbook anterior."
