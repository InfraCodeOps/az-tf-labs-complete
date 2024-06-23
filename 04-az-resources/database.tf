resource "random_password" "db_server_password" {
  length  = 16
  special = true
  lower   = true
  upper   = true
  numeric = true
}

resource "random_string" "db_server_suffix" {
  length  = 4
  special = false
  upper   = false
}

# create an az sql server
resource "azurerm_mssql_server" "infra_sql_server" {
  name                         = "infra-sql-server-${random_string.db_server_suffix.result}"
  resource_group_name          = azurerm_resource_group.infra_rg.name
  location                     = azurerm_resource_group.infra_rg.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = random_password.db_server_password.result
}


# create an az sql database
resource "azurerm_mssql_database" "infra_sql_db" {
  name        = "infra-sql-db-${random_string.db_server_suffix.result}"
  server_id   = azurerm_mssql_server.infra_sql_server.id
  collation   = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb = 2
  sku_name    = "Basic"
}


output "infra_sql_server_password" {
  sensitive = true
  value     = azurerm_mssql_server.infra_sql_server.administrator_login_password
}


# validate create of server using:
# az sql server show --name $(terraform output -raw sql_server_name) \
# --resource-group "infra-rg-04"
output "sql_server_name" {
  value = azurerm_mssql_server.infra_sql_server.name
}

# validate database using:
# az sql db show --name $(terraform output -raw sql_database_name) \
# --server $(terraform output -raw sql_server_name) \
# --resource-group "infra-rg-04"     
#
output "sql_database_name" {
  value = azurerm_mssql_database.infra_sql_db.name
}
