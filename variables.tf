variable "name" {
  description = "Base name used for local network gateways and VPN connections."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name used for local network gateways and VPN connections."
  type        = string
}

variable "location" {
  description = "Azure region for local network gateways and VPN connections."
  type        = string
}

variable "local_network_gateways" {
  description = "Map of local network gateways keyed by logical name."
  type = map(object({
    name            = optional(string)
    gateway_address = string
    address_space   = list(string)
    bgp_settings = optional(object({
      asn                 = optional(number)
      bgp_peering_address = optional(string)
      peer_weight         = optional(number)
    }))
  }))
}

variable "vpn_connections" {
  description = "Map of VPN connections keyed by logical name."
  type = map(object({
    name                               = optional(string)
    type                               = optional(string, "IPsec")
    virtual_network_gateway_id         = string
    local_network_gateway_key          = string
    shared_key                         = optional(string)
    enable_bgp                         = optional(bool, false)
    connection_mode                    = optional(string)
    connection_protocol                = optional(string)
    dpd_timeout_seconds                = optional(number)
    local_azure_ip_address_enabled     = optional(bool)
    routing_weight                     = optional(number)
    use_policy_based_traffic_selectors = optional(bool, false)
    ipsec_policy = optional(object({
      dh_group         = string
      ike_encryption   = string
      ike_integrity    = string
      ipsec_encryption = string
      ipsec_integrity  = string
      pfs_group        = string
      sa_datasize      = number
      sa_lifetime      = number
    }))
    traffic_selector_policies = optional(list(object({
      local_address_cidrs  = list(string)
      remote_address_cidrs = list(string)
    })), [])
  }))
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
