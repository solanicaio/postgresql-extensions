# SPDX-FileCopyrightText: Copyright © contributors to CloudNativePG, established as CloudNativePG a Series of LF Projects, LLC.
# SPDX-License-Identifier: Apache-2.0

ARG BASE=ghcr.io/cloudnative-pg/postgresql:18.7-minimal-trixie
FROM $BASE AS builder

ARG PG_MAJOR
ARG PG_SERVER_DEV
ARG EXT_VERSION

USER 0

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      cmake \
      libssl-dev \
      "postgresql-server-dev-${PG_MAJOR}=${PG_SERVER_DEV}"

ADD --checksum=sha256:c49c9615b2b6623f1c3ad2813b850d4c577d6c65c43bb8eee4b255e1e1af4a9f \
    https://github.com/timescale/timescaledb/archive/refs/tags/${EXT_VERSION}.tar.gz /tmp/timescaledb.tar.gz

RUN mkdir -p /src && \
    tar -xzf /tmp/timescaledb.tar.gz --strip-components=1 -C /src && \
    cmake -S /src -B /build \
      -DAPACHE_ONLY=ON \
      -DREGRESS_CHECKS=OFF \
      -DSEND_TELEMETRY_DEFAULT=OFF \
      -DPG_CONFIG="/usr/lib/postgresql/${PG_MAJOR}/bin/pg_config" && \
    cmake --build /build --parallel 2 && \
    DESTDIR=/out cmake --install /build

FROM scratch
ARG PG_MAJOR

COPY --from=builder /src/LICENSE /licenses/timescaledb/
COPY --from=builder /out/usr/lib/postgresql/${PG_MAJOR}/lib/timescaledb* /lib/
COPY --from=builder /out/usr/share/postgresql/${PG_MAJOR}/extension/timescaledb* /share/extension/

USER 65532:65532
