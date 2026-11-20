# SPDX-FileCopyrightText: Copyright © contributors to CloudNativePG, established as CloudNativePG a Series of LF Projects, LLC.
# SPDX-License-Identifier: Apache-2.0
metadata = {
  name                     = "pg-partman"
  sql_name                 = "pg_partman"
  image_name               = "pg-partman"
  licenses                 = ["PostgreSQL"]
  # The background worker that runs partition maintenance on a schedule.
  shared_preload_libraries = ["pg_partman_bgw"]
  postgresql_parameters    = {
    # The extension must be created in this database (the test database).
    "pg_partman_bgw.dbname" = "app"
    # The default role (partman_maintainer) does not exist; maintenance runs
    # as the owner of the partitioned tables.
    "pg_partman_bgw.role"   = "app"
  }
  extension_control_path   = []
  dynamic_library_path     = []
  ld_library_path          = []
  bin_path                 = []
  env                      = {}
  auto_update_os_libs      = false
  required_extensions      = []
  create_extension         = true

  versions = {
    trixie = {
      "18" = {
        // renovate: suite=trixie-pgdg depName=postgresql-18-partman
        package = "5.5.0-1.pgdg13+2"
        // renovate: suite=trixie-pgdg depName=postgresql-18-partman extractVersion=^(?<version>\d+\.\d+\.\d+)
        sql     = "5.5.0"
      }
      "19" = {
        // renovate: suite=trixie-pgdg depName=postgresql-19-partman
        package = "5.5.0-1.pgdg13+2"
        // renovate: suite=trixie-pgdg depName=postgresql-19-partman extractVersion=^(?<version>\d+\.\d+\.\d+)
        sql     = "5.5.0"
      }
    }
    bookworm = {
      "18" = {
        // renovate: suite=bookworm-pgdg depName=postgresql-18-partman
        package = "5.5.0-1.pgdg12+2"
        // renovate: suite=bookworm-pgdg depName=postgresql-18-partman extractVersion=^(?<version>\d+\.\d+\.\d+)
        sql     = "5.5.0"
      }
      "19" = {
        // renovate: suite=bookworm-pgdg depName=postgresql-19-partman
        package = "5.5.0-1.pgdg12+2"
        // renovate: suite=bookworm-pgdg depName=postgresql-19-partman extractVersion=^(?<version>\d+\.\d+\.\d+)
        sql     = "5.5.0"
      }
    }
  }
}
