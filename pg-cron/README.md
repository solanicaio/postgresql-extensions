# pg_cron
<!--
SPDX-FileCopyrightText: Copyright © contributors to CloudNativePG, established as CloudNativePG a Series of LF Projects, LLC.
SPDX-License-Identifier: Apache-2.0
-->

[pg_cron](https://github.com/citusdata/pg_cron) is a cron-based job scheduler
for PostgreSQL that runs inside the database as a background worker, letting
you schedule SQL commands with the familiar cron syntax.

## Usage

### 1. Add the pg_cron extension image to your Cluster

Define the `pg-cron` extension under the `postgresql.extensions` section of
your `Cluster` resource. pg_cron must be loaded via `shared_preload_libraries`,
and needs two parameters:

- `cron.database_name`: the database in which the extension is created and
  where the job metadata lives (default `postgres`);
- `cron.use_background_workers`: run jobs in background workers. Otherwise
  pg_cron opens libpq connections to `localhost`, which the CloudNativePG
  `pg_hba` rules reject without a password.

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: cluster-pg-cron
spec:
  imageName: ghcr.io/cloudnative-pg/postgresql:18-minimal-trixie
  instances: 1

  bootstrap:
    initdb:
      postInitApplicationSQL:
        - ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT USAGE ON SCHEMAS TO app

  storage:
    size: 1Gi

  postgresql:
    shared_preload_libraries:
      - "pg_cron"
    parameters:
      cron.database_name: app
      cron.use_background_workers: "on"
    extensions:
    - name: pg-cron
      image:
        # renovate: suite=trixie-pgdg depName=postgresql-18-cron
        reference: ghcr.io/solanicaio/pg-cron:1.6.8-18-trixie
```

pg_cron installs its objects in the `cron` schema, owned by the superuser that
runs `CREATE EXTENSION`. The application user needs `USAGE` on that schema to
schedule jobs; the `postInitApplicationSQL` above grants it through default
privileges. pg_cron refuses a pre-created `cron` schema, so do not declare it
in the `Database` resource. On an existing cluster, run as superuser after
creating the extension:

```sql
GRANT USAGE ON SCHEMA cron TO app;
```

Each running job uses a background worker, shared with parallel queries and
logical replication through `max_worker_processes` (default 8). Raise it if
you run many jobs at the same time.

### 2. Enable the extension in a database

Create the extension in the database set in `cron.database_name` by creating
or updating a `Database` resource. For example, for the `app` database:

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Database
metadata:
  name: cluster-pg-cron-app
spec:
  name: app
  owner: app
  cluster:
    name: cluster-pg-cron
  extensions:
  - name: pg_cron
    # renovate: suite=trixie-pgdg depName=postgresql-18-cron extractVersion=^(?<version>\d+\.\d+)
    version: '1.6'
```

### 3. Verify installation

Once the database is ready, connect to it with `psql` as the `app` user and
schedule a job:

```sql
CREATE TABLE ticks (t timestamptz NOT NULL DEFAULT now());
SELECT cron.schedule('tick', '* * * * *', $$INSERT INTO ticks DEFAULT VALUES$$);
-- A minute later
SELECT * FROM cron.job_run_details ORDER BY start_time DESC LIMIT 5;
SELECT cron.unschedule('tick');
```

Jobs run as the user who scheduled them. The scheduler runs only on the
primary; the job definitions are stored in the database and replicated, so
jobs resume on the new primary after a switchover or failover.

## Licenses and Copyright

This container image contains software that may be licensed under various
open-source licenses.

All relevant license and copyright information for the `pg_cron` extension
and its dependencies are bundled within the image at:

```text
/licenses/
```

By using this image, you agree to comply with the terms of the licenses
contained therein.
