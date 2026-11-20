# SPDX-FileCopyrightText: Copyright © contributors to CloudNativePG, established as CloudNativePG a Series of LF Projects, LLC.
# SPDX-License-Identifier: Apache-2.0
metadata = {
  name                     = "timescaledb-oss"
  sql_name                 = "timescaledb"
  image_name               = "timescaledb-oss"
  licenses                 = ["Apache-2.0", "PostgreSQL"]
  shared_preload_libraries = ["timescaledb"]
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
      "18.6" = {
        pg_major       = "18"
        pg_version     = "18.6"
        pg_server_dev  = "18.6-1.pgdg13+2"
        package        = "2.32.1"
        sql            = "2.32.1"
      }
      "18.7" = {
        pg_major       = "18"
        pg_version     = "18.7"
        pg_server_dev  = "18.7-1.pgdg13+2"
        package        = "2.32.1"
        sql            = "2.32.1"
      }
    }
    bookworm = {
      "18.6" = {
        pg_major       = "18"
        pg_version     = "18.6"
        pg_server_dev  = "18.6-1.pgdg12+2"
        package        = "2.32.1"
        sql            = "2.32.1"
      }
      "18.7" = {
        pg_major       = "18"
        pg_version     = "18.7"
        pg_server_dev  = "18.7-1.pgdg12+2"
        package        = "2.32.1"
        sql            = "2.32.1"
      }
    }
  }
}
