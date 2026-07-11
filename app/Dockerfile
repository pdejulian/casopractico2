# =============================================================================
# Dockerfile - Imagen mínima de prueba para validar el flujo ACR (Sesión 1)
# Esta NO es la app final de Podman/Kubernetes: es solo para comprobar que
# el registro funciona (build -> push -> pull) antes de avanzar a la Sesión 2.
# =============================================================================
FROM docker.io/nginx:alpine

COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80
