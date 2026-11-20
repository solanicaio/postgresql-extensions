# pg_partman
<!--
SPDX-FileCopyrightText: Copyright © contributors to CloudNativePG, established as CloudNativePG a Series of LF Projects, LLC.
SPDX-License-Identifier: Apache-2.0
-->

[pg_partman](https://github.com/pgpartman/pg_partman) automates the creation
and retention of time- and number-based partitions on top of PostgreSQL native
declarative partitioning. Its optional background worker runs the partition
maintenance on a schedule.

The image contains the extension and the background worker. The Python
scripts of the upstream package (`dump_partition.py`, `vacuum_maintenance.py`,
`check_unique_constraint.py`) are not included.

## Usage

### 1. Add the pg_partman extension image to your Cluster

Define the `pg-partman` extension under the `postgresql.extensions` section of
your `Cluster` resource. To run maintenance automatically, load the background
worker via `shared_preload_libraries` and set:

- `pg_partman_bgw.dbname`: the database in which the extension is created;
- `pg_partman_bgw.role`: the role that runs maintenance. The default,
  `partman_maintainer`, does not exist; use the role that owns the partitioned
  tables;
- `pg_partman_bgw.interval`: seconds between maintenance runs (default `3600`).

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: cluster-pg-partman
spec:
  imageName: ghcr.io/cloudnative-pg/postgresql:18-minimal-trixie
  instances: 1

  bootstrap:
    initdb:
      postInitApplicationSQL:
        - CREATE SCHEMA partman
        - GRANT ALL ON SCHEMA partman TO app
        - ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA partman GRANT ALL ON TABLES TO app

  storage:
    size: 1Gi

  postgresql:
    shared_preload_libraries:
      - "pg_partman_bgw"
    parameters:
      pg_partman_bgw.dbname: app
      pg_partman_bgw.role: app
    extensions:
    - name: pg-partman
      image:
        # renovate: suite=trixie-pgdg depName=postgresql-18-partman
        reference: ghcr.io/solanicaio/pg-partman:5.5.0-18-trixie
```

The `Database` resource runs `CREATE EXTENSION` as the superuser, so the
extension's configuration tables belong to it. A non-superuser that manages
partitions needs to create objects in the extension schema (pg_partman keeps a
template table there for each partition set) and to write to those tables; the
`postInitApplicationSQL` above grants both to `app`. On an existing cluster,
run as superuser instead:

```sql
CREATE SCHEMA partman;
GRANT ALL ON SCHEMA partman TO app;
-- After creating the extension
GRANT ALL ON ALL TABLES IN SCHEMA partman TO app;
```

Without the background worker, call `partman.run_maintenance_proc()`
periodically, for example with [pg_cron](../pg-cron/README.md).

> [!NOTE]
> On PostgreSQL 18.7 and later, each background worker run that finds the
> extension installed ends with `ERROR: cannot drop portal "<unnamed portal 1>"
> while it is being set up` and exit code 1 in the PostgreSQL log. Maintenance
> is committed before the error, so it still takes effect. This is a
> pg_partman 5.5.0 incompatibility with a check added in that PostgreSQL
> release.

### 2. Enable the extension in a database

Create the extension in the database set in `pg_partman_bgw.dbname` by
creating or updating a `Database` resource. For example, for the `app`
database:

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Database
metadata:
  name: cluster-pg-partman-app
spec:
  name: app
  owner: app
  cluster:
    name: cluster-pg-partman
  extensions:
  - name: pg_partman
    schema: partman
    # renovate: suite=trixie-pgdg depName=postgresql-18-partman extractVersion=^(?<version>\d+\.\d+\.\d+)
    version: '5.5.0'
```

### 3. Verify installation

Once the database is ready, connect to it with `psql` as the `app` user and
partition a table:

```sql
CREATE TABLE events (id bigint NOT NULL, created_at timestamptz NOT NULL DEFAULT now())
  PARTITION BY RANGE (created_at);
SELECT partman.create_parent(
  p_parent_table := 'public.events',
  p_control := 'created_at',
  p_interval := '1 day'
);
SELECT * FROM partman.show_partitions('public.events');
```

The background worker then keeps `premake` partitions (default 4) ahead of the
newest data. It runs as `pg_partman_bgw.role`, so that role must own the
partitioned tables or be a member of the roles that own them. The worker runs
only on the primary; the configuration is stored in the database and
replicated, so maintenance resumes on the new primary after a switchover or
failover.

## Licenses and Copyright

This container image contains software that may be licensed under various
open-source licenses.

All relevant license and copyright information for the `pg_partman` extension
and its dependencies are bundled within the image at:

```text
/licenses/
```

By using this image, you agree to comply with the terms of the licenses
contained therein.
