# pg_repack
<!--
SPDX-FileCopyrightText: Copyright © contributors to CloudNativePG, established as CloudNativePG a Series of LF Projects, LLC.
SPDX-License-Identifier: Apache-2.0
-->

[pg_repack](https://github.com/reorg/pg_repack) removes bloat from tables and
indexes and can restore the physical order of clustered indexes. Unlike
`VACUUM FULL` and `CLUSTER`, it holds an exclusive lock only briefly, so the
table stays available for reads and writes while it is rebuilt.

pg_repack has two parts: the `pg_repack` extension in the database, and the
`pg_repack` client that drives the rebuild. This image ships both: the client
is at `bin/pg_repack` and links only against the `libpq` of the PostgreSQL
image.

## Usage

### 1. Add the pg_repack extension image to your Cluster

Define the `pg-repack` extension under the `postgresql.extensions` section of
your `Cluster` resource:

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: cluster-pg-repack
spec:
  imageName: ghcr.io/cloudnative-pg/postgresql:18-minimal-trixie
  instances: 1

  storage:
    size: 1Gi

  postgresql:
    extensions:
    - name: pg-repack
      image:
        # renovate: suite=trixie-pgdg depName=postgresql-18-repack
        reference: ghcr.io/solanicaio/pg-repack:1.5.3-18-trixie
```

### 2. Enable the extension in a database

Install `pg_repack` in every database whose tables you want to repack by
creating or updating a `Database` resource. For example, for the `app`
database:

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Database
metadata:
  name: cluster-pg-repack-app
spec:
  name: app
  owner: app
  cluster:
    name: cluster-pg-repack
  extensions:
  - name: pg_repack
    # renovate: suite=trixie-pgdg depName=postgresql-18-repack extractVersion=^(?<version>\d+\.\d+\.\d+)
    version: '1.5.3'
```

### 3. Run the client

The client must run as a superuser, and its version must match the extension.
Tables need a primary key or a unique index on `NOT NULL` columns.

From the primary instance, where the image is mounted under
`/extensions/pg-repack` and the `postgres` user connects through the local
socket:

```sh
kubectl exec -it cluster-pg-repack-1 -c postgres -- \
  /extensions/pg-repack/bin/pg_repack --dbname=app --table=public.my_table
```

Or as a `Job` that mounts this image as a volume into the PostgreSQL image,
connecting with the superuser secret (`enableSuperuserAccess: true`):

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: repack-my-table
spec:
  template:
    spec:
      restartPolicy: Never
      securityContext:
        runAsUser: 26
        runAsNonRoot: true
      containers:
      - name: pg-repack
        image: ghcr.io/cloudnative-pg/postgresql:18-minimal-trixie
        env:
        - name: PGHOST
          value: cluster-pg-repack-rw
        - name: PGDATABASE
          value: app
        - name: PGUSER
          valueFrom:
            secretKeyRef:
              name: cluster-pg-repack-superuser
              key: username
        - name: PGPASSWORD
          valueFrom:
            secretKeyRef:
              name: cluster-pg-repack-superuser
              key: password
        command: ["/pg-repack/bin/pg_repack", "--table=public.my_table"]
        volumeMounts:
        - name: pg-repack
          mountPath: /pg-repack
      volumes:
      - name: pg-repack
        image:
          # renovate: suite=trixie-pgdg depName=postgresql-18-repack
          reference: ghcr.io/solanicaio/pg-repack:1.5.3-18-trixie
```

## Licenses and Copyright

This container image contains software that may be licensed under various
open-source licenses.

All relevant license and copyright information for the `pg_repack` extension
and its dependencies are bundled within the image at:

```text
/licenses/
```

By using this image, you agree to comply with the terms of the licenses
contained therein.
