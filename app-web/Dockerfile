# =============================================================================
# Dockerfile - Servidor web Nginx con HTTPS y autenticación básica
# Sesión 2: app desplegada en la VM mediante Podman (distinta de la de AKS)
# =============================================================================
FROM docker.io/nginx:alpine

# Herramientas necesarias para generar el certificado y las credenciales
RUN apk add --no-cache openssl apache2-utils

# Certificado x.509 autofirmado (autocontenido, sin dependencias externas)
RUN mkdir -p /etc/nginx/certs && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
      -keyout /etc/nginx/certs/server.key \
      -out /etc/nginx/certs/server.crt \
      -subj "/C=ES/O=UNIR/CN=casopractico2.local"

# Usuario y contraseña para autenticación básica (alumno / unir2026)
RUN htpasswd -cb /etc/nginx/.htpasswd alumno unir2026

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY index.html /usr/share/nginx/html/index.html

EXPOSE 443
