# SPDX-FileCopyrightText: Copyright © contributors to CloudNativePG, established as CloudNativePG a Series of LF Projects, LLC.
# SPDX-License-Identifier: Apache-2.0

ARG BASE=ghcr.io/cloudnative-pg/postgresql:18-minimal-trixie
FROM $BASE AS builder

ARG PG_MAJOR
ARG EXT_VERSION
ARG MIN_PG_BUILD_MINOR

USER 0

# Timescale's package revision encodes the PostgreSQL release it was compiled
# against (e.g. 2.31.0~debian13-1806 -> 18.6). Refuse builds older than the
# declared ABI floor: PostgreSQL minors occasionally break the extension ABI
# (e.g. 18.7, CVE-2026-6460) and the server can't detect the mismatch.
RUN if [ -n "${MIN_PG_BUILD_MINOR}" ]; then \
      built="${EXT_VERSION##*-}" && \
      built_major="${built%??}" && \
      built_minor="${built#"${built_major}"}" && \
      built_minor="${built_minor#0}" && \
      if [ "${built_major}" != "${PG_MAJOR}" ] || [ "${built_minor}" -lt "${MIN_PG_BUILD_MINOR}" ]; then \
        echo "ERROR: ${EXT_VERSION} was built against PostgreSQL ${built_major}.${built_minor}; need ${PG_MAJOR}.${MIN_PG_BUILD_MINOR} or newer (min_pg_build_minor)" >&2; \
        exit 1; \
      fi; \
    fi

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

# Oldest release this repository has published. The loader loads the library of
# the version installed in the database, so a newer image must still ship the
# libraries of older published releases: without them every query fails until
# ALTER EXTENSION timescaledb UPDATE runs.
ARG UPGRADE_FROM_VERSION=2.31.0

# The package keeps the libraries and install scripts of every past release;
# ship the loader, the libraries since UPGRADE_FROM_VERSION, this release and
# the scripts that update to it.
RUN version="${EXT_VERSION%%~*}" && \
    lib="/usr/lib/postgresql/${PG_MAJOR}/lib" && \
    share="/usr/share/postgresql/${PG_MAJOR}/extension" && \
    mkdir -p /out/lib /out/share && \
    cp "${lib}/timescaledb.so" /out/lib/ && \
    for so in "${lib}"/timescaledb-[0-9]*.so; do \
      v="${so##*/timescaledb-}" && v="${v%.so}" && \
      if [ "$(printf '%s\n%s\n' "${UPGRADE_FROM_VERSION}" "${v}" | sort -V | head -n1)" = "${UPGRADE_FROM_VERSION}" ]; then \
        cp "${so}" /out/lib/ && \
        if [ -f "${lib}/timescaledb-tsl-${v}.so" ]; then cp "${lib}/timescaledb-tsl-${v}.so" /out/lib/; fi; \
      fi; \
    done && \
    test -f "/out/lib/timescaledb-${version}.so" && test -f "/out/lib/timescaledb-tsl-${version}.so" && \
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
