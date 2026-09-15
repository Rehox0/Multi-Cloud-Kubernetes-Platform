FROM alpine:3.24.1
ARG KUBECTL_VERSION=v1.35.8

RUN apk add --no-cache \
        ca-certificates \
        curl \
    && curl -fsSL \
        -o /usr/local/bin/kubectl \
        "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
    && chmod +x /usr/local/bin/kubectl \
    && kubectl version --client

ENTRYPOINT ["/bin/sh"]