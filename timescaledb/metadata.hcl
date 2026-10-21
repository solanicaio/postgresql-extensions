# SPDX-FileCopyrightText: Copyright © contributors to CloudNativePG, established as CloudNativePG a Series of LF Projects, LLC.
# SPDX-License-Identifier: Apache-2.0
metadata = {
  name                     = "timescaledb"
  sql_name                 = "timescaledb"
  image_name               = "timescaledb"
  licenses                 = ["Apache-2.0", "LicenseRef-Timescale"]
  shared_preload_libraries = ["timescaledb"]
  postgresql_parameters    = {
    "timescaledb.telemetry_level" = "off"
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
        // renovate: repo=timescale suite=trixie depName=timescaledb-2-postgresql-18
        package = "2.31.0~debian13-1806"
        // renovate: repo=timescale suite=trixie depName=timescaledb-2-postgresql-18 extractVersion=^(?<version>\d+\.\d+\.\d+)
        sql = "2.31.0"
      }
    }
    bookworm = {
      "18" = {
        // renovate: repo=timescale suite=bookworm depName=timescaledb-2-postgresql-18
        package = "2.31.0~debian12-1806"
        // renovate: repo=timescale suite=bookworm depName=timescaledb-2-postgresql-18 extractVersion=^(?<version>\d+\.\d+\.\d+)
        sql = "2.31.0"
      }
    }
  }
}
