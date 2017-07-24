ARG SOURCE
ARG VERSION
FROM ${SOURCE}:${VERSION}

RUN apk --no-cache add \
    build-base \
    go \
    musl-dev \
    git \
    xz \
    openssh-client \
    tar \
    curl

CMD ["/bin/bash"]
