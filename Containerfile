ARG PARENT_IMAGE=registry.access.redhat.com/ubi9-micro

FROM registry.access.redhat.com/ubi9
ARG RUSTIC_VERSION
ARG TARGETARCH
RUN if [ "$TARGETARCH" = "amd64" ]; then ARCH=x86_64; \
    elif [ "$TARGETARCH" = "i386" ]; then ARCH=i686; \
    elif [ "$TARGETARCH" = "arm64" ]; then ARCH=aarch64; \
    fi \
 && curl -fsSL https://github.com/rustic-rs/rustic/releases/download/$RUSTIC_VERSION/rustic-$RUSTIC_VERSION-$ARCH-unknown-linux-musl.tar.gz | tar -C /tmp -xz


FROM $PARENT_IMAGE
ARG PARENT_IMAGE
ARG RUSTIC_VERSION

EXPOSE 8080

VOLUME ["/home/rustic/.cache/rustic"]

ENV RUSTIC_VERSION=${RUSTIC_VERSION} \
    SUMMARY="Running Rustic ${RUSTIC_VERSION} applications" \
    DESCRIPTION=""

LABEL io.k8s.description="$DESCRIPTION" \
      io.k8s.display-name="Rustic $RUSTIC_VERSION" \
      maintainer="Tobias Florek <tob@butter.sh>" \
      summary="$SUMMARY" \
      description="$DESCRIPTION" \
      version="$RUSTIC_VERSION" \
      name="quay.io/ibotty/rustic" \
      parent_image=$PARENT_IMAGE

RUN echo 'default:x:1001:0:Default Application User:/home/rustic:/bin/bash' >> /etc/passwd \
 && mkdir -p /home/rustic \
 && chown 1001:0 /home/rustic

COPY --from=0 /tmp/rustic /usr/local/bin/rustic

USER 1001
WORKDIR /home/rustic

ENTRYPOINT ["/usr/local/bin/rustic"]
