FROM amd64/alpine:latest

RUN apk add --no-cache curl bash kubectl

COPY scripts/healthcheck.sh /usr/local/bin/healthcheck.sh

RUN chmod +x /usr/local/bin/healthcheck.sh

ENTRYPOINT [ "/usr/local/bin/healthcheck.sh" ]