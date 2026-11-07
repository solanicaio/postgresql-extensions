# SPDX-FileCopyrightText: Copyright © contributors to CloudNativePG, established as CloudNativePG a Series of LF Projects, LLC.
# SPDX-License-Identifier: Apache-2.0
metadata = {
  name                     = "pg-cron"
  sql_name                 = "pg_cron"
  image_name               = "pg-cron"
  licenses                 = ["PostgreSQL"]
  # The scheduler is a background worker started by the postmaster.
  shared_preload_libraries = ["pg_cron"]
  postgresql_parameters    = {
    # The extension must be created in this database (the test database).
    "cron.database_name"          = "app"
    # Run jobs in background workers instead of libpq connections to
    # localhost, which the CloudNativePG pg_hba rules reject without a password.
    "cron.use_background_workers" = "on"
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
        // renovate: suite=trixie-pgdg depName=postgresql-18-cron
        package = "1.6.8-1.pgdg13+2"
        // renovate: suite=trixie-pgdg depName=postgresql-18-cron extractVersion=^(?<version>\d+\.\d+)
        sql     = "1.6"
      }
    }
    bookworm = {
      "18" = {
        // renovate: suite=bookworm-pgdg depName=postgresql-18-cron
        package = "1.6.8-1.pgdg12+2"
        // renovate: suite=bookworm-pgdg depName=postgresql-18-cron extractVersion=^(?<version>\d+\.\d+)
        sql     = "1.6"
      }
    }
  }
}
