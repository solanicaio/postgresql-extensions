# SPDX-FileCopyrightText: Copyright © contributors to CloudNativePG, established as CloudNativePG a Series of LF Projects, LLC.
# SPDX-License-Identifier: Apache-2.0

ARG BASE=ghcr.io/cloudnative-pg/postgresql:18-minimal-trixie
FROM $BASE AS builder

ARG PG_MAJOR
ARG EXT_VERSION

USER 0

RUN apt-get update && \
    apt-get install -y --no-install-recommends "postgresql-${PG_MAJOR}-repack=${EXT_VERSION}"

FROM scratch
ARG PG_MAJOR

# Licenses
COPY --from=builder /usr/share/doc/postgresql-${PG_MAJOR}-repack/copyright /licenses/postgresql-${PG_MAJOR}-repack/

# Client, linked only against libpq from the PostgreSQL image
COPY --from=builder /usr/lib/postgresql/${PG_MAJOR}/bin/pg_repack /bin/

# Libraries
COPY --from=builder /usr/lib/postgresql/${PG_MAJOR}/lib/pg_repack.so /lib/
COPY --from=builder /usr/lib/postgresql/${PG_MAJOR}/lib/bitcode/pg_repack /lib/bitcode/pg_repack/
COPY --from=builder /usr/lib/postgresql/${PG_MAJOR}/lib/bitcode/pg_repack.index.bc /lib/bitcode/

# Share
COPY --from=builder /usr/share/postgresql/${PG_MAJOR}/extension/pg_repack* /share/extension/

USER 65532:65532
