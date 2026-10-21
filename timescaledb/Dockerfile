# SPDX-FileCopyrightText: Copyright © contributors to CloudNativePG, established as CloudNativePG a Series of LF Projects, LLC.
# SPDX-License-Identifier: Apache-2.0

ARG BASE=ghcr.io/cloudnative-pg/postgresql:18-minimal-trixie
FROM $BASE AS builder

ARG PG_MAJOR
ARG EXT_VERSION

USER 0

# The community edition (with the Timescale License components) is only
# published in Timescale's repository; PGDG ships the Apache-2.0 edition.
ADD --chmod=644 https://packagecloud.io/timescale/timescaledb/gpgkey /etc/apt/keyrings/timescaledb.asc

RUN . /etc/os-release && \
    echo "deb [signed-by=/etc/apt/keyrings/timescaledb.asc] https://packagecloud.io/timescale/timescaledb/debian/ ${VERSION_CODENAME} main" \
      > /etc/apt/sources.list.d/timescaledb.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      "timescaledb-2-postgresql-${PG_MAJOR}=${EXT_VERSION}" \
      "timescaledb-2-loader-postgresql-${PG_MAJOR}=${EXT_VERSION}"

# The package keeps the libraries and install scripts of every past release;
# ship only the loader, this release and the scripts that update to it.
RUN version="${EXT_VERSION%%~*}" && \
    lib="/usr/lib/postgresql/${PG_MAJOR}/lib" && \
    share="/usr/share/postgresql/${PG_MAJOR}/extension" && \
    mkdir -p /out/lib /out/share && \
    cp "${lib}/timescaledb.so" "${lib}/timescaledb-${version}.so" "${lib}/timescaledb-tsl-${version}.so" /out/lib/ && \
    cp "${share}/timescaledb.control" "${share}/timescaledb--${version}.sql" "${share}"/timescaledb--*--"${version}".sql /out/share/

FROM scratch
ARG PG_MAJOR

# Licenses
COPY --from=builder /usr/share/doc/timescaledb-2-postgresql-${PG_MAJOR}/copyright /licenses/timescaledb-2-postgresql-${PG_MAJOR}/
COPY --from=builder /usr/share/doc/timescaledb-2-loader-postgresql-${PG_MAJOR}/copyright /licenses/timescaledb-2-loader-postgresql-${PG_MAJOR}/
COPY LICENSE-TIMESCALE /licenses/timescaledb-2-postgresql-${PG_MAJOR}/

# Libraries
COPY --from=builder /out/lib/ /lib/

# Share
COPY --from=builder /out/share/ /share/extension/

USER 65532:65532
