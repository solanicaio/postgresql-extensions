# SPDX-FileCopyrightText: Copyright © contributors to CloudNativePG, established as CloudNativePG a Series of LF Projects, LLC.
# SPDX-License-Identifier: Apache-2.0

ARG BASE=ghcr.io/cloudnative-pg/postgresql:18-minimal-trixie
FROM $BASE AS builder

ARG PG_MAJOR
ARG EXT_VERSION

USER 0

RUN apt-get update && \
    apt-get install -y --no-install-recommends "postgresql-${PG_MAJOR}-partman=${EXT_VERSION}"

FROM scratch
ARG PG_MAJOR

# Licenses
COPY --from=builder /usr/share/doc/postgresql-${PG_MAJOR}-partman/copyright /licenses/postgresql-${PG_MAJOR}-partman/

# Libraries: only the background worker, the extension itself is SQL.
# The package's Python scripts are left out: they need Python and psycopg2.
COPY --from=builder /usr/lib/postgresql/${PG_MAJOR}/lib/pg_partman_bgw.so /lib/
COPY --from=builder /usr/lib/postgresql/${PG_MAJOR}/lib/bitcode/src/pg_partman_bgw /lib/bitcode/src/pg_partman_bgw/
COPY --from=builder /usr/lib/postgresql/${PG_MAJOR}/lib/bitcode/src/pg_partman_bgw.index.bc /lib/bitcode/src/

# Share
COPY --from=builder /usr/share/postgresql/${PG_MAJOR}/extension/pg_partman* /share/extension/

USER 65532:65532
