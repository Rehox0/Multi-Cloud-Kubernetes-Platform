FROM alpine:3.22

RUN apk add --no-cache ca-certificates curl \
    && curl -L \
       -o /usr/local/bin/kubectl \
       https://dl.k8s.io/release/v1.35.0/bin/linux/amd64/kubectl \
    && chmod +x /usr/local/bin/kubectl

ENTRYPOINT ["/bin/sh"]