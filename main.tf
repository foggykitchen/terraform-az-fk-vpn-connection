resource "azurerm_local_network_gateway" "this" {
  for_each = var.local_network_gateways

  name                = coalesce(try(each.value.name, null), "${var.name}-${each.key}-lng")
  location            = var.location
  resource_group_name = var.resource_group_name
  gateway_address     = each.value.gateway_address
  address_space       = each.value.address_space

  dynamic "bgp_settings" {
    for_each = try(each.value.bgp_settings, null) == null ? [] : [each.value.bgp_settings]
    content {
      asn                 = try(bgp_settings.value.asn, null)
      bgp_peering_address = try(bgp_settings.value.bgp_peering_address, null)
      peer_weight         = try(bgp_settings.value.peer_weight, null)
    }
  }

  tags = var.tags
}

resource "azurerm_virtual_network_gateway_connection" "this" {
  for_each = var.vpn_connections

  name                = coalesce(try(each.value.name, null), "${var.name}-${each.key}-conn")
  location            = var.location
  resource_group_name = var.resource_group_name

  type                               = try(each.value.type, "IPsec")
  virtual_network_gateway_id         = each.value.virtual_network_gateway_id
  local_network_gateway_id           = azurerm_local_network_gateway.this[each.value.local_network_gateway_key].id
  shared_key                         = try(each.value.shared_key, null)
  enable_bgp                         = try(each.value.enable_bgp, false)
  connection_mode                    = try(each.value.connection_mode, null)
  connection_protocol                = try(each.value.connection_protocol, null)
  dpd_timeout_seconds                = try(each.value.dpd_timeout_seconds, null)
  local_azure_ip_address_enabled     = try(each.value.local_azure_ip_address_enabled, null)
  routing_weight                     = try(each.value.routing_weight, null)
  use_policy_based_traffic_selectors = try(each.value.use_policy_based_traffic_selectors, false)

  dynamic "ipsec_policy" {
    for_each = try(each.value.ipsec_policy, null) == null ? [] : [each.value.ipsec_policy]
    content {
      dh_group         = ipsec_policy.value.dh_group
      ike_encryption   = ipsec_policy.value.ike_encryption
      ike_integrity    = ipsec_policy.value.ike_integrity
      ipsec_encryption = ipsec_policy.value.ipsec_encryption
      ipsec_integrity  = ipsec_policy.value.ipsec_integrity
      pfs_group        = ipsec_policy.value.pfs_group
      sa_datasize      = ipsec_policy.value.sa_datasize
      sa_lifetime      = ipsec_policy.value.sa_lifetime
    }
  }

  dynamic "traffic_selector_policy" {
    for_each = try(each.value.traffic_selector_policies, [])
    content {
      local_address_cidrs  = traffic_selector_policy.value.local_address_cidrs
      remote_address_cidrs = traffic_selector_policy.value.remote_address_cidrs
    }
  }

  tags = var.tags
}
