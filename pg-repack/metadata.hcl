# SPDX-FileCopyrightText: Copyright © contributors to CloudNativePG, established as CloudNativePG a Series of LF Projects, LLC.
# SPDX-License-Identifier: Apache-2.0
metadata = {
  name                     = "pg-repack"
  sql_name                 = "pg_repack"
  image_name               = "pg-repack"
  licenses                 = ["BSD-3-Clause"]
  shared_preload_libraries = []
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
        // renovate: suite=trixie-pgdg depName=postgresql-18-repack
        package = "1.5.3-1.pgdg13+2"
        // renovate: suite=trixie-pgdg depName=postgresql-18-repack extractVersion=^(?<version>\d+\.\d+\.\d+)
        sql     = "1.5.3"
      }
    }
    bookworm = {
      "18" = {
        // renovate: suite=bookworm-pgdg depName=postgresql-18-repack
        package = "1.5.3-1.pgdg12+2"
        // renovate: suite=bookworm-pgdg depName=postgresql-18-repack extractVersion=^(?<version>\d+\.\d+\.\d+)
        sql     = "1.5.3"
      }
    }
  }
}
