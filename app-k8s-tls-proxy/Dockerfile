# =============================================================================
# Dockerfile - Proxy Nginx con certificado x.509 autofirmado (sidecar TLS)
# =============================================================================
# Imagen 100% autocontenida: el certificado se genera durante el build, sin
# depender de Let's Encrypt/certbot ni de ningun paso manual posterior.
# =============================================================================
FROM nginx:1.27-alpine

RUN apk add --no-cache openssl \
    && mkdir -p /etc/nginx/certs \
    && openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
       -keyout /etc/nginx/certs/server.key \
       -out /etc/nginx/certs/server.crt \
       -subj "/C=ES/O=UNIR/CN=cp2.unir.local"

COPY nginx-tls.conf /etc/nginx/conf.d/default.conf

EXPOSE 443
