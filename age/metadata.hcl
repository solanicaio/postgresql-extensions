# SPDX-FileCopyrightText: Copyright © contributors to CloudNativePG, established as CloudNativePG a Series of LF Projects, LLC.
# SPDX-License-Identifier: Apache-2.0
metadata = {
  name                     = "age"
  sql_name                 = "age"
  image_name               = "age"
  licenses                 = ["Apache-2.0", "PostgreSQL"]
  # Non-superusers can only LOAD libraries from $libdir/plugins, which image
  # volumes cannot provide, so AGE must be preloaded.
  shared_preload_libraries = ["age"]
  postgresql_parameters    = {}
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
        // renovate: suite=trixie-pgdg depName=postgresql-18-age
        package = "1.8.0~rc0-2.pgdg13+1"
        // renovate: suite=trixie-pgdg depName=postgresql-18-age extractVersion=^(?<version>\d+\.\d+\.\d+)
        sql     = "1.8.0"
      }
    }
    bookworm = {
      "18" = {
        // renovate: suite=bookworm-pgdg depName=postgresql-18-age
        package = "1.8.0~rc0-2.pgdg12+1"
        // renovate: suite=bookworm-pgdg depName=postgresql-18-age extractVersion=^(?<version>\d+\.\d+\.\d+)
        sql     = "1.8.0"
      }
    }
  }
}
