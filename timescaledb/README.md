# TimescaleDB (Community Edition)
<!--
SPDX-FileCopyrightText: Copyright © contributors to CloudNativePG, established as CloudNativePG a Series of LF Projects, LLC.
SPDX-License-Identifier: Apache-2.0
-->

[TimescaleDB](https://github.com/timescale/timescaledb) is a time-series
database built on PostgreSQL. This image ships the **Community Edition**: the
Apache-2.0 core plus the components licensed under the
[Timescale License (TSL)](https://github.com/timescale/timescaledb/blob/main/tsl/LICENSE-TIMESCALE),
such as columnstore compression, continuous aggregates, and compression,
retention and refresh policies.

> [!IMPORTANT]
> The TSL components are **not** open source. The Timescale License allows
> internal use, and use as part of value-added products or services, but
> **prohibits offering TimescaleDB to third parties as a database service**
> (DBaaS). By using this image you agree to the
> [Timescale License](https://github.com/timescale/timescaledb/blob/main/tsl/LICENSE-TIMESCALE),
> a copy of which is bundled at
> `/licenses/timescaledb-2-postgresql-<major>/LICENSE-TIMESCALE`. Use it only
> for internal use or if you otherwise hold a license from Timescale (Tiger
> Data).
>
> For the Apache-2.0 edition only, use
> [`ghcr.io/cloudnative-pg/timescaledb-oss`](https://github.com/cloudnative-pg/postgres-extensions-containers/tree/main/timescaledb-oss).

The binaries come unmodified from Timescale's
[package repository](https://packagecloud.io/timescale/timescaledb). Only the
libraries of the packaged release, its install script and the scripts that
update older releases to it are included.

## Usage

### 1. Add the TimescaleDB extension image to your Cluster

Define the `timescaledb` extension under the `postgresql.extensions` section
of your `Cluster` resource. TimescaleDB must be loaded via
`shared_preload_libraries`. For example:

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: cluster-timescaledb
spec:
  imageName: ghcr.io/cloudnative-pg/postgresql:18-minimal-trixie
  instances: 1

  storage:
    size: 1Gi

  postgresql:
    shared_preload_libraries:
      - "timescaledb"
    parameters:
      timescaledb.telemetry_level: 'off'
      max_locks_per_transaction: '128'

    extensions:
    - name: timescaledb
      image:
        # renovate: repo=timescale suite=trixie depName=timescaledb-2-postgresql-18
        reference: ghcr.io/solanicaio/timescaledb:2.31.0-18-trixie
```

### 2. Enable the extension in a database

You can install `timescaledb` in a specific database by creating or updating a
`Database` resource. For example, to enable it in the `app` database:

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Database
metadata:
  name: cluster-timescaledb-app
spec:
  name: app
  owner: app
  cluster:
    name: cluster-timescaledb
  extensions:
  - name: timescaledb
    # renovate: repo=timescale suite=trixie depName=timescaledb-2-postgresql-18 extractVersion=^(?<version>\d+\.\d+\.\d+)
    version: '2.31.0'
```

### 3. Verify installation

Once the database is ready, connect to it with `psql` and check that the
Timescale License components are active:

```sql
SHOW timescaledb.license;  -- timescale
\dx
```

## Licenses and Copyright

This container image contains software licensed under the Apache License 2.0
and under the Timescale License.

All relevant license and copyright information for the `timescaledb`
extension and its dependencies are bundled within the image at:

```text
/licenses/
```

By using this image, you agree to comply with the terms of the licenses
contained therein.
