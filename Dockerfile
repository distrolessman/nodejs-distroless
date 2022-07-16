FROM docker.io/bitnami/minideb:buster as builder
ARG DEBIAN_FRONTEND=noninteractive
ARG resolvingdeps=https://github.com/tran4774/Resolving-Shared-Library/releases/download/v1.0.3/resolving.sh

ADD ${resolvingdeps} /home/resolvingdeps.sh

WORKDIR /home
RUN \
    bash -c "apt-get update && apt-get install -y curl unzip \
    && curl -fsSL https://fnm.vercel.app/install | bash \
    && chmod +x resolvingdeps.sh"
ARG SDK_IDENTIFIER=v16.16.0
RUN \
    bash -c " \
    source /root/.bashrc \
    && fnm install --fnm-dir /home/nodejs/ $SDK_IDENTIFIER \
    && ./resolvingdeps.sh -p /home/nodejs/aliases/default"

FROM gcr.io/distroless/static
COPY --from=builder /home/nodejs/aliases/default/ /usr/local/nodejs/
COPY --from=builder /home/deps/ /
COPY --from=builder /usr/bin/env /usr/bin/
ENV NODE_HOME=/usr/local/nodejs
ENV PATH=$PATH:$NODE_HOME/bin
CMD ["node", "--version"]
