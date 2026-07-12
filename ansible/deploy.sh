#!/usr/bin/env bash
# =============================================================================
# deploy.sh - Despliega TODO de forma automatica: Terraform + Ansible
# =============================================================================
set -euo pipefail
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

echo ">>> Despliegue completado."
IP=$(terraform -chdir="$DIR_TERRAFORM" output -raw ip_publica_vm)
echo ">>> Prueba la web con:"
echo "    curl -k -u alumno:unir2026 https://$IP/"
