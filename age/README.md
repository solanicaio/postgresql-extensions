# Apache AGE
<!--
SPDX-FileCopyrightText: Copyright © contributors to CloudNativePG, established as CloudNativePG a Series of LF Projects, LLC.
SPDX-License-Identifier: Apache-2.0
-->

[Apache AGE](https://age.apache.org/) is a PostgreSQL extension that provides
graph database functionality, letting you query graphs with openCypher
alongside regular SQL.

## Usage

### 1. Add the AGE extension image to your Cluster

Define the `age` extension under the `postgresql.extensions` section of your
`Cluster` resource. AGE must be loaded via `shared_preload_libraries`:
non-superusers can only `LOAD` libraries from `$libdir/plugins`, which is not
available with image volumes.

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: cluster-age
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
      - "age"
    extensions:
    - name: age
      image:
        # renovate: suite=trixie-pgdg depName=postgresql-18-age
        reference: ghcr.io/solanicaio/age:1.8.0-18-trixie
```

AGE installs its objects in the `ag_catalog` schema, owned by the superuser
that runs `CREATE EXTENSION`. The application user needs `USAGE` on that
schema to create and query graphs; the `postInitApplicationSQL` above grants it
through default privileges. AGE refuses to install into a pre-created
`ag_catalog` owned by another role, so do not declare the schema in the
`Database` resource. On an existing cluster, run as superuser after creating
the extension:

```sql
GRANT USAGE ON SCHEMA ag_catalog TO app;
```

### 2. Enable the extension in a database

You can install `age` in a specific database by creating or updating a
`Database` resource. For example, to enable it in the `app` database:

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Database
metadata:
  name: cluster-age-app
spec:
  name: app
  owner: app
  cluster:
    name: cluster-age
  extensions:
  - name: age
    # renovate: suite=trixie-pgdg depName=postgresql-18-age extractVersion=^(?<version>\d+\.\d+\.\d+)
    version: '1.8.0'
```

### 3. Verify installation

Once the database is ready, connect to it with `psql` as the `app` user and
run (graph names must be at least 3 characters long):

```sql
SET search_path = ag_catalog, "$user", public;
SELECT create_graph('my_graph');
SELECT * FROM cypher('my_graph', $$
  CREATE (:Person {name: 'Alice'})-[:KNOWS]->(:Person {name: 'Bob'})
$$) AS (v agtype);
SELECT * FROM cypher('my_graph', $$
  MATCH (a:Person)-[:KNOWS]->(b:Person) RETURN a.name, b.name
$$) AS (a agtype, b agtype);
```

## Licenses and Copyright

This container image contains software that may be licensed under various
open-source licenses.

All relevant license and copyright information for the `age` extension
and its dependencies are bundled within the image at:

```text
/licenses/
```

By using this image, you agree to comply with the terms of the licenses
contained therein.
