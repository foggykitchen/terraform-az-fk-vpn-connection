# terraform-az-fk-vpn-connection

This repository contains a reusable **Terraform / OpenTofu module** for deploying **Azure Local Network Gateways** and **site-to-site VPN connections** bound to an existing Azure Virtual Network Gateway.

---

## Purpose

The module is designed for composable Azure VPN patterns where:

- the Azure Virtual Network Gateway is managed separately
- one or more remote VPN tunnel endpoints must be modeled explicitly
- IPSec connection settings should stay reusable and payload-driven

It is intended to compose cleanly with `terraform-az-fk-vng` and cloud-specific VPN edge modules.

---

## What the module does

The module creates:

- one or more `azurerm_local_network_gateway` resources
- one or more `azurerm_virtual_network_gateway_connection` resources

The module intentionally does **not** create:

- Resource Groups
- Virtual Networks
- Gateway subnets
- Virtual Network Gateways
- Public IPs

Those resources should be composed separately.

---

## Example Usage

```hcl
module "vpn_connection" {
  source = "git::https://github.com/mlinxfeld/terraform-az-fk-vpn-connection.git?ref=v0.1.0"

  name                = "vpn-fk-demo"
  location            = "westeurope"
  resource_group_name = "rg-fk-demo"

  local_network_gateways = {
    tunnel1 = {
      gateway_address = module.oci_ipsec.tunnels["0"].vpn_ip
      address_space   = ["192.168.0.0/16"]
    }
  }

  vpn_connections = {
    tunnel1 = {
      virtual_network_gateway_id = module.vng.gateway_id
      local_network_gateway_key  = "tunnel1"
      shared_key                 = "FoggyKitchenDemoSecret01!"
    }
  }
}
```

---

## Inputs

| Variable | Required | Description |
|------|------|-------------|
| `name` | ✅ | Base name for local gateways and VPN connections |
| `resource_group_name` | ✅ | Resource group name |
| `location` | ✅ | Azure region |
| `local_network_gateways` | ✅ | Map of local network gateways |
| `vpn_connections` | ✅ | Map of VPN connections |
| `tags` | ❌ | Resource tags |

### Local network gateway schema

```hcl
local_network_gateways = map(object({
  name            = optional(string)
  gateway_address = string
  address_space   = list(string)
  bgp_settings = optional(object({
    asn                 = optional(number)
    bgp_peering_address = optional(string)
    peer_weight         = optional(number)
  }))
}))
```

### VPN connection schema

```hcl
vpn_connections = map(object({
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
```

---

## Outputs

| Output | Description |
|------|-------------|
| `local_network_gateway_ids` | Map of local network gateway IDs |
| `local_network_gateway_names` | Map of local network gateway names |
| `vpn_connection_ids` | Map of VPN connection IDs |
| `vpn_connection_names` | Map of VPN connection names |

---

## License

Licensed under the **Universal Permissive License (UPL), Version 1.0**.
