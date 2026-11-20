# `TimescaleDB` (Apache-2.0 Edition)

This image contains TimescaleDB 2.32.1 built with `APACHE_ONLY=ON`. It contains
the Apache-2.0 implementation and excludes Timescale License components.

The image is built separately against PostgreSQL 18.6 and 18.7:

| PostgreSQL | Trixie | Bookworm |
|---|---|---|
| 18.6 | `ghcr.io/solanicaio/timescaledb-oss:2.32.1-18.6-trixie` | `ghcr.io/solanicaio/timescaledb-oss:2.32.1-18.6-bookworm` |
| 18.7 | `ghcr.io/solanicaio/timescaledb-oss:2.32.1-18.7-trixie` | `ghcr.io/solanicaio/timescaledb-oss:2.32.1-18.7-bookworm` |

Building against each exact PostgreSQL minor is intentional. PostgreSQL 18.7
introduced an extension ABI/background-worker compatibility change, so the
provider must select the matching image by version range.

## Usage

```yaml
spec:
  imageName: ghcr.io/cloudnative-pg/postgresql:18.7-minimal-trixie
  postgresql:
    shared_preload_libraries:
      - timescaledb
    parameters:
      timescaledb.telemetry_level: "off"
      max_locks_per_transaction: "128"
    extensions:
      - name: timescaledb-oss
        image:
          reference: ghcr.io/solanicaio/timescaledb-oss:2.32.1-18.7-trixie
```

Create the extension in a `Database` resource with SQL version `2.32.1`.
