FROM alpine:3.10

RUN apk update && \
    apk add \
      gcc \
      g++ \
      musl-dev \
      fts-dev \
      make \
      patch \
      libxml2-dev \
      openssl-dev \
      xz-dev \
      bash \
      clang \
      llvm \
      clang-dev \
      xz \
      tar \
      cmake \
      git

COPY musl-fts.patch /opt

RUN git clone https://github.com/tpoechtrager/osxcross.git /usr/osxcross && \
    cd /usr/osxcross && \
    patch -p1 -i /opt/musl-fts.patch

COPY sdks/* /usr/osxcross/tarballs/

RUN cd /usr/osxcross && \
    OSX_VERSION_MIN=10.10 UNATTENDED=1 ./build.sh && \
    ln -s target/bin && \
    rm -rf build && \
    rm -rf wrapper

RUN for f in /usr/osxcross/bin/*-ar ; do \
      rm -v "$f" ; \
      printf '#!/bin/sh\n' > "$f" ; \
      printf 'exec llvm-ar "$@"\n' >> "$f" ; \
      chmod +x "$f" ; \
    done

ENV PATH /usr/osxcross/bin:$PATH
