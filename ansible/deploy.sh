#!/usr/bin/env bash
# =============================================================================
# deploy.sh - Orquesta la ejecución del playbook de la Sesión 2
# =============================================================================
set -euo pipefail

echo "Instalando la colección de Ansible para Podman (si falta)..."
ansible-galaxy collection install containers.podman

echo "Comprobando conectividad con la VM..."
ansible podman_vm -m ping -i hosts

echo "Ejecutando el playbook..."
ansible-playbook -i hosts playbook.yml

echo "Despliegue completado."
