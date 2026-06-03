# terraform-az-fk-vpn-connection

This repository contains a reusable **Terraform/OpenTofu module** for deploying **Azure VPN edge connectivity primitives** such as **Local Network Gateways** and **site-to-site VPN connections** bound to an existing Azure Virtual Network Gateway.

It is part of the **[FoggyKitchen.com training ecosystem](https://foggykitchen.com/courses-2/)** and serves as the Azure VPN edge building block for hybrid and multicloud connectivity patterns.

Support expectations are documented in [SUPPORT.md](SUPPORT.md).

---

## 🎯 Purpose

The goal of this module is to provide a **clean, composable, and educational reference implementation** for Azure VPN edge connectivity:

- Focused on **Local Network Gateway and VPN connection resources**
- No hidden Virtual Network Gateway, VNet, subnet, or Public IP creation
- Designed to be composed with **terraform-az-fk-vng** and cloud-specific VPN edge modules

This is **not** a full landing zone replacement. It is a **connectivity edge module** intended for learning, reuse, and composition.

---

## ✨ What the module does

The module creates:

- Azure Local Network Gateways
- Azure site-to-site VPN connections
- Optional BGP settings on Local Network Gateways
- Optional IPSec policy and traffic selector settings on VPN connections

The module intentionally does **not** create:

- Resource Groups
- Virtual Networks
- Gateway subnets
- Virtual Network Gateways
- Public IPs

Each of those concerns belongs in its own dedicated module or composition layer.

---

## 📂 Repository Structure

```bash
terraform-az-fk-vpn-connection/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── LICENSE
└── README.md
```

---

## 🚀 Example Usage

```hcl
module "vpn_connection" {
  source = "git::https://github.com/foggykitchen/terraform-az-fk-vpn-connection.git?ref=v0.1.1"

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

## ⚙️ Module Inputs

### Core inputs

| Variable | Type | Required | Description |
|--------|------|----------|-------------|
| `name` | `string` | ✅ | Base name used for local gateways and VPN connections |
| `resource_group_name` | `string` | ✅ | Resource group name |
| `location` | `string` | ✅ | Azure region |
| `tags` | `map(string)` | ❌ | Resource tags |

### Connectivity objects

| Variable | Type | Required | Description |
|--------|------|----------|-------------|
| `local_network_gateways` | `map(object)` | ✅ | Map of local network gateways keyed by logical name |
| `vpn_connections` | `map(object)` | ✅ | Map of VPN connections keyed by logical name |

### Local network gateway object schema

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

### VPN connection object schema

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

## 📤 Outputs

| Output | Description |
|------|-------------|
| `local_network_gateway_ids` | Map of local network gateway IDs |
| `local_network_gateway_names` | Map of local network gateway names |
| `vpn_connection_ids` | Map of VPN connection IDs |
| `vpn_connection_names` | Map of VPN connection names |

---

## 🧠 Design Philosophy

- Explicit over implicit
- Small modules over monoliths
- Azure Virtual Network Gateway separated from VPN connection edge configuration
- Optimized for **learning, reuse, and composition**

This makes the module useful for:

- Azure-to-OCI site-to-site VPN
- Hybrid VPN foundations
- Multicloud VPN labs
- Progressive connectivity building blocks

---

## 📌 Notes

- This module focuses on Azure VPN edge primitives rather than full topologies
- Azure gateway creation should remain modeled in **terraform-az-fk-vng**
- VNet, GatewaySubnet, and Public IP ownership should remain explicit and separate

---

## 🌐 Learn More

Visit [FoggyKitchen.com](https://foggykitchen.com/) for Azure, multicloud, and Terraform/OpenTofu learning resources.

---

## 🪪 License

Licensed under the **Universal Permissive License (UPL), Version 1.0**.  
See [LICENSE](LICENSE) for details.

---

© 2026 [FoggyKitchen.com](https://foggykitchen.com) - Cloud. Code. Clarity.
