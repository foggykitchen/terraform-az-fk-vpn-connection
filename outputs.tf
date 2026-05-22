output "local_network_gateway_ids" {
  description = "Map of local network gateway keys to resource IDs."
  value = {
    for key, gateway in azurerm_local_network_gateway.this : key => gateway.id
  }
}

output "local_network_gateway_names" {
  description = "Map of local network gateway keys to names."
  value = {
    for key, gateway in azurerm_local_network_gateway.this : key => gateway.name
  }
}

output "vpn_connection_ids" {
  description = "Map of VPN connection keys to resource IDs."
  value = {
    for key, connection in azurerm_virtual_network_gateway_connection.this : key => connection.id
  }
}

output "vpn_connection_names" {
  description = "Map of VPN connection keys to names."
  value = {
    for key, connection in azurerm_virtual_network_gateway_connection.this : key => connection.name
  }
}
