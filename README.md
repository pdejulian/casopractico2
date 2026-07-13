# Caso Práctico 2 — Automatización de despliegues en entornos Cloud

Despliegue totalmente automatizado en Microsoft Azure de un registro de imágenes privado (ACR), una aplicación web en contenedor sobre una máquina virtual Linux con Podman, y un clúster de Kubernetes (AKS) con una aplicación (WordPress + MySQL) que usa almacenamiento persistente.

Toda la infraestructura se crea con **Terraform** y toda la configuración/despliegue de aplicaciones se realiza con **Ansible**, sin ningún paso manual en el portal de Azure.

---

## Arquitectura

```
Terraform ──► crea ──► ACR + VM Linux + AKS (Azure)
Ansible   ──► configura y despliega ──► App web en Podman (VM) + WordPress/MySQL (AKS)

Internet ──HTTPS──► VM Podman (Nginx + x.509 + htpasswd)
Internet ──HTTPS──► AKS Service LoadBalancer ──► WordPress (+ sidecar TLS) ──► MySQL (PVC)
```

Componentes:

| Componente | Tecnología | Descripción |
|---|---|---|
| Registro de imágenes | Azure Container Registry (ACR) | Registro privado, tag `casopractico2` en todas las imágenes |
| App VM | Podman + Nginx | Servidor web HTTPS con certificado x.509 autofirmado y autenticación básica (htpasswd), como servicio systemd |
| Clúster | Azure Kubernetes Service (AKS) | 1 nodo worker, integrado con el ACR mediante el rol `AcrPull` sobre la identidad del kubelet |
| App K8s | WordPress + MySQL | Almacenamiento persistente con PVC sobre `managed-csi` (Azure Disk), expuesta con Service `LoadBalancer` y sidecar TLS |

---

## Requisitos previos

- Cuenta de Azure
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) (`az`)
  curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.9
  wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt-get update && sudo apt-get install -y terraform
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/index.html) >= 2.12
  sudo apt-get install -y ansible
- [Podman](https://podman.io/docs/installation) (o Docker)
  sudo apt-get install -y podman
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
  sudo apt-get install -y kubectl
- Python 3 + pip
  sudo apt install -y python3 python3-pip
- Par de claves SSH generado en el nodo de control

### Login en Azure

```bash
az login
az account set --subscription "<ID_SUSCRIPCION>"
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
```

---

## Estructura del repositorio

```
casopractico2/
├── README.md
├── LICENSE
├── .gitignore
├── destroy.sh           # Destruye TODOS los recursos de Azure
├── terraform/              # Infraestructura como código (ACR, VM, AKS)
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── acr.tf
│   ├── vm.tf
│   └── aks.tf
├── ansible/                # Configuración y despliegue (sin shell/command)
│   ├── deploy.sh            # Script maestro: un solo comando, despliega TODO
│   ├── hosts                # Inventario (generado/actualizado por Terraform)
│   ├── playbook.yml          # Despliega la app web en la VM (Podman)
│   ├── playbook_imagen_proxy.yml  # Build + push del sidecar TLS
│   └── playbook_wordpress.yml     # Despliega WordPress + MySQL + PVC en AKS
├── app-web/                # Imagen 1: servidor web en Podman (VM) — Dockerfile, cert.pem, htpasswd
└── app-k8s/                 # Imagen 2: app de Kubernetes (distinta de la anterior)
```

---

## Despliegue: un solo comando

```bash
cd ansible
chmod +x deploy.sh
./deploy.sh
```

El script `deploy.sh` ejecuta, en orden, todo lo necesario para dejar el entorno completo funcionando:

1. `terraform init` + `terraform apply` → crea ACR, VM y AKS.
2. Inventario y variables generados automaticamente por Terraform.
3. Instalando colecciones de Ansible necesarias
4. Construyendo y subiendo la imagen de la app web al ACR
5. Esperando a que la VM responda por SSH
6. Desplegando el servidor web en Podman (VM)
7. Obtiene las credenciales del clúster AKS (`kubeconfig`).
8. Construyendo y subiendo la imagen del proxy TLS (Ansible + Podman)
9. Despliega WordPress + MySQL con persistencia (PVC) en AKS.

Al finalizar, el script muestra la IP pública de la VM y las instrucciones para verificar ambas aplicaciones.

---

## Verificación

### App en la VM (Podman)

```bash
curl -k -u alumno:unir2026 https://<IP_VM>/
```

### App en Kubernetes (WordPress)

```bash
kubectl get pods
kubectl get pvc
kubectl get svc wordpress-svc
```

Abre `https://<EXTERNAL-IP>/` en el navegador. Para comprobar la persistencia:

```bash
kubectl delete pod -l app=wordpress
kubectl get pods -w   # el pod se recrea solo (self-healing)
```

Los datos deben seguir intactos porque residen en el PVC (Azure Disk), no en el pod.

---

## Destrucción del entorno

```bash
cd ansible
chmod +x destroy.sh
./destroy.sh
```

Este script borra las apps de Kubernetes, detiene el contenedor de la VM, ejecuta `terraform destroy` (elimina ACR, VM, AKS y el grupo de recursos completo) y limpia el contexto local de `kubectl`. Verifica en el [portal de Azure](https://portal.azure.com) que el grupo de recursos ha desaparecido.

Tras destruir, puedes volver a desplegar todo desde cero simplemente con `./deploy.sh`.

---

## Variables y personalización

Las variables principales se configuran en `terraform/variables.tf`:

| Variable | Descripción | Valor por defecto |
|---|---|---|
| `location` | Región de Azure | `spaincentral` |
| `acr_sku` | SKU del Container Registry | `Basic` |
| `vm_size` | Tamaño de la VM | `Standard_B2ats_v2` |
| `aks_node_count` | Nº de nodos worker de AKS | `1` |
| `image_tag` | Tag de las imágenes de contenedor | `casopractico2` |

---

## Licencia

Este proyecto se distribuye bajo la licencia [MIT](LICENSE). Consulta el fichero `LICENSE` para el texto completo y las condiciones de uso.
