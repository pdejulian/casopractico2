#!/usr/bin/env bash
# destroy.sh - Destruye TODO el Caso Practico 2 para poder relanzarlo desde cero
# Uso: ./destroy.sh
set -euo pipefail

echo "=========================================="
echo "  CASO PRACTICO 2 - Destruccion completa"
echo "=========================================="
echo

read -rp "Esto borrara TODOS los recursos de Azure (ACR, VM, AKS). Continuar? [s/N] " confirm
if [[ ! "$confirm" =~ ^[sS]$ ]]; then
    echo "Cancelado."
    exit 0
fi

# ------------------------------------------------------------------
# 1) Eliminar las apps de Kubernetes (opcional, pero mas limpio)
#    Si el AKS ya no existe o kubectl no conecta, no debe frenar el script.
# ------------------------------------------------------------------
echo
echo "[1/4] Eliminando apps de Kubernetes (si el cluster esta accesible)..."
if command -v kubectl &>/dev/null && kubectl cluster-info &>/dev/null; then
    if [ -f "ansible/playbook-k8s.yml" ]; then
        ansible-playbook ansible/playbook-k8s.yml --extra-vars "k8s_state=absent" || true
    else
        kubectl delete deployment,service,pvc,secret -l app=wordpress --ignore-not-found=true || true
        kubectl delete deployment,service,pvc,secret -l app=mysql --ignore-not-found=true || true
    fi
    echo "    Apps de Kubernetes eliminadas (o no encontradas)."
else
    echo "    kubectl no conecta al cluster (probablemente ya no existe). Se omite este paso."
fi

# ------------------------------------------------------------------
# 2) Detener/eliminar el contenedor Podman de la VM (opcional)
#    Se hace via Ansible si el playbook lo soporta; si la VM ya no
#    existe, este paso simplemente fallara y se ignora.
# ------------------------------------------------------------------
echo
echo "[2/4] Deteniendo el contenedor Podman en la VM (si es accesible)..."
if [ -f "ansible/playbook-podman.yml" ]; then
    ansible-playbook ansible/playbook-podman.yml --extra-vars "podman_state=absent" || echo "    VM no accesible o ya eliminada. Se omite."
else
    echo "    No se encontro ansible/playbook-podman.yml. Se omite."
fi

# ------------------------------------------------------------------
# 3) Destruir TODA la infraestructura de Azure con Terraform
#    Esto borra ACR, VM, AKS, red, grupo de recursos, etc.
# ------------------------------------------------------------------
echo
echo "[3/4] Destruyendo infraestructura de Azure con Terraform..."
if [ -d "terraform" ]; then
    terraform -chdir=terraform destroy -auto-approve
    echo "    Infraestructura destruida correctamente."
else
    echo "    ERROR: no se encontro el directorio terraform/"
    exit 1
fi

# ------------------------------------------------------------------
# 4) Limpieza local: contexto de kubectl, clave, hosts y credenciales cacheadas
# ------------------------------------------------------------------
echo
echo "[4/4] Limpiando contexto local de kubectl..."
CLUSTER_NAME="$(grep -oP '(?<=name\s*=\s*")[^"]+' terraform/aks.tf 2>/dev/null | head -1 || echo "")"
if [ -n "$CLUSTER_NAME" ] && command -v kubectl &>/dev/null; then
    kubectl config delete-context "$CLUSTER_NAME" 2>/dev/null || true
    kubectl config delete-cluster "$CLUSTER_NAME" 2>/dev/null || true
    kubectl config unset "users.clusterUser_$CLUSTER_NAME" 2>/dev/null || true
    echo "    Contexto local de kubectl eliminado."
else
    echo "    No se pudo determinar el nombre del cluster o kubectl no esta instalado. Se omite."
fi
rm -f "/srv/casopractico2/ansible/clave_ssh_vm" "/srv/casopractico2/ansible/clave_ssh_vm.pub"  "/srv/casopractico2/ansible/hosts"

echo
echo "=========================================="
echo "  Limpieza completa."
echo "  Verifica en el portal de Azure que el"
echo "  grupo de recursos ha desaparecido."
echo "  Puedes relanzar todo con ./deploy.sh"
echo "=========================================="
