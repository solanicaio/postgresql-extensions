# postgresql-extensions
PostgreSQL extensions collection that can be used in Kubernetes with ImageVolumes

Images follow the [CloudNativePG image volume extension](https://cloudnative-pg.io/docs/current/imagevolume_extensions/)
layout and are built with the same tooling as
[cloudnative-pg/postgres-extensions-containers](https://github.com/cloudnative-pg/postgres-extensions-containers)
(see [BUILD.md](BUILD.md)), so extensions can be proposed upstream unchanged.

Images are published to `ghcr.io/solanicaio/<extension>:<version>-<pg major>-<distro>`.

| Extension | Image | Docs |
|-----------|-------|------|
| [Apache AGE](https://age.apache.org/) | `ghcr.io/solanicaio/age` | [age/README.md](age/README.md) |
| [TimescaleDB Community](https://github.com/timescale/timescaledb) ¹ | `ghcr.io/solanicaio/timescaledb` | [timescaledb/README.md](timescaledb/README.md) |

¹ Includes components under the
[Timescale License](https://github.com/timescale/timescaledb/blob/main/tsl/LICENSE-TIMESCALE),
which is not open source and prohibits offering TimescaleDB to third parties
as a database service. Use it only for internal use or if you hold a license
from Timescale.
