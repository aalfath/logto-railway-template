# Logto (https://github.com/logto-io/logto), official image pinned by version and digest.
FROM svhd/logto:1.46.0@sha256:d5e208ce705cbcf7c79ddba421216eb65413d0b0531aa658fb22a4ba659be983

# Railway's edge terminates TLS and sends X-Forwarded-* headers.
ENV TRUST_PROXY_HEADER=1

COPY start.sh /etc/logto/railway-start.sh
RUN chmod +x /etc/logto/railway-start.sh

EXPOSE 3001 3002
ENTRYPOINT ["/etc/logto/railway-start.sh"]
