output "endpoint" {
  value = azurerm_container_app.this.ingress[0].fqdn
}

output "resource_id" {
  value = azurerm_container_app.this.id
}
