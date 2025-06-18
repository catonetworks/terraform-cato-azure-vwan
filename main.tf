################################################################################
# Resource Definitions
################################################################################

# --- Azure Resources ---

# Create random shared keys for the VPN connections, only if not provided.
resource "random_password" "shared_key_primary" {
  count   = var.primary_connection_shared_key == null ? 1 : 0
  length  = 32
  special = true
}

resource "random_password" "shared_key_secondary" {
  # Only create if a secondary connection is used and key is not provided.
  count   = var.secondary_cato_pop_ip != null && var.secondary_connection_shared_key == null ? 1 : 0
  length  = 32
  special = true
}

# Define the VPN Gateway in the Azure VWAN Hub.
resource "azurerm_vpn_gateway" "cato_vpn_gateway" {
  name                = var.custom_vpn_gateway_name == null ? "${var.site_name}-azure-vpn-gateway" : var.custom_vpn_gateway_name
  location            = data.azurerm_virtual_hub.hub.location
  resource_group_name = data.azurerm_resource_group.rg.name
  virtual_hub_id      = data.azurerm_virtual_hub.hub.id
  tags                = var.tags
  bgp_settings {
    asn         = var.azure_asn
    peer_weight = var.azure_bgp_peer_weight
    instance_0_bgp_peering_address {
      custom_ips = [var.azure_primary_bgp_ip]
    }
    dynamic "instance_1_bgp_peering_address" {
      for_each = var.azure_secondary_bgp_ip != null ? [1] : []
      content {
        custom_ips = [var.azure_secondary_bgp_ip]
      }
    }
  }
}

# Define the VPN Site, representing the Cato PoPs.
resource "azurerm_vpn_site" "cato_vpn_site" {
  name                = var.custom_vpn_site_name == null ? "${var.site_name}-azure-vpn-site" : var.custom_vpn_site_name
  location            = data.azurerm_virtual_hub.hub.location
  resource_group_name = data.azurerm_resource_group.rg.name
  address_cidrs       = var.bgp_enabled ? var.cato_site_address_cidrs : var.cato_local_networks
  virtual_wan_id      = data.azurerm_virtual_wan.vwan.id
  tags                = var.tags

  # Primary link is always created.
  link {
    name          = var.vpn_site_primary_link_name
    ip_address    = var.primary_cato_pop_ip
    speed_in_mbps = var.upstream_bw # Bandwidth is symmetrical
    bgp {
      asn             = var.cato_asn
      peering_address = var.cato_primary_bgp_ip
    }
  }

  # Secondary link is created dynamically if a secondary IP is provided.
  dynamic "link" {
    for_each = var.secondary_cato_pop_ip != null ? [1] : []
    content {
      name          = var.vpn_site_secondary_link_name
      ip_address    = var.secondary_cato_pop_ip
      speed_in_mbps = var.upstream_bw # Bandwidth is symmetrical
      bgp {
        asn             = var.cato_asn
        peering_address = var.cato_secondary_bgp_ip
      }
    }
  }
}

resource "azurerm_vpn_gateway_connection" "cato_vpn_gateway_connection" {
  name               = var.custom_vpn_gateway_connection_name == null ? "${var.site_name}-azure-vpn-connection" : var.custom_vpn_gateway_connection_name
  vpn_gateway_id     = azurerm_vpn_gateway.cato_vpn_gateway.id
  remote_vpn_site_id = azurerm_vpn_site.cato_vpn_site.id

  # Primary VPN link is always created.
  vpn_link {
    name             = var.vpn_site_primary_link_name
    vpn_site_link_id = azurerm_vpn_site.cato_vpn_site.link[0].id
    bandwidth_mbps   = var.upstream_bw # Bandwidth is symmetrical
    shared_key       = var.primary_connection_shared_key == null ? random_password.shared_key_primary[0].result : var.primary_connection_shared_key
    bgp_enabled      = var.bgp_enabled

    ipsec_policy {
      dh_group                 = var.azure_ipsec_dh_group
      ike_encryption_algorithm = var.azure_ipsec_ike_encryption
      ike_integrity_algorithm  = var.azure_ipsec_ike_integrity
      encryption_algorithm     = var.azure_ipsec_encryption
      integrity_algorithm      = var.azure_ipsec_integrity
      pfs_group                = var.azure_ipsec_pfs_group
      sa_data_size_kb          = var.ipsec_sa_data_size_kb
      sa_lifetime_sec          = var.ipsec_sa_lifetime_sec
    }
  }

  # Secondary VPN link is created dynamically.
  dynamic "vpn_link" {
    for_each = var.secondary_cato_pop_ip != null ? [1] : []
    content {
      name             = var.vpn_site_secondary_link_name
      vpn_site_link_id = azurerm_vpn_site.cato_vpn_site.link[1].id
      bandwidth_mbps   = var.upstream_bw # Bandwidth is symmetrical
      shared_key       = var.secondary_connection_shared_key == null ? random_password.shared_key_secondary[0].result : var.secondary_connection_shared_key
      bgp_enabled      = var.bgp_enabled

      ipsec_policy {
        dh_group                 = var.azure_ipsec_dh_group
        ike_encryption_algorithm = var.azure_ipsec_ike_encryption
        ike_integrity_algorithm  = var.azure_ipsec_ike_integrity
        encryption_algorithm     = var.azure_ipsec_encryption
        integrity_algorithm      = var.azure_ipsec_integrity
        pfs_group                = var.azure_ipsec_pfs_group
        sa_data_size_kb          = var.ipsec_sa_data_size_kb
        sa_lifetime_sec          = var.ipsec_sa_lifetime_sec
      }
    }
  }
}

# --- Cato Resources ---

# Create the IPsec site in the Cato Management Application using the correct syntax.
resource "cato_ipsec_site" "ipsec_site" {
  name                 = var.site_name
  site_type            = var.site_type
  description          = var.site_description
  native_network_range = var.native_network_range == null ? data.azurerm_virtual_hub.hub.address_prefix : var.native_network_range
  site_location        = var.site_location # Pass the object directly

  ipsec = {
    primary = {
      public_cato_ip_id = data.cato_allocatedIp.primary[0].items[0].id
      # destination_type  = var.primary_destination_type
      # pop_location_id   = var.primary_pop_location_id
      tunnels = [
        {
          public_site_ip  = local.azure_primary_public_ip
          private_cato_ip = var.bgp_enabled ? var.cato_primary_bgp_ip : null
          private_site_ip = var.bgp_enabled ? var.azure_primary_bgp_ip : null
          psk             = var.primary_connection_shared_key == null ? random_password.shared_key_primary[0].result : var.primary_connection_shared_key
          last_mile_bw = {
            downstream = var.downstream_bw
            upstream   = var.upstream_bw
          }
        }
      ]
    }
    # The secondary block is defined conditionally based on the presence of the secondary pop ip variable.
    secondary = var.secondary_cato_pop_ip != null ? {
      public_cato_ip_id = data.cato_allocatedIp.secondary[0].items[0].id
      # destination_type  = var.secondary_destination_type
      # pop_location_id   = var.secondary_pop_location_id
      tunnels = [
        {
          public_site_ip  = local.azure_secondary_public_ip
          private_cato_ip = var.bgp_enabled ? var.cato_secondary_bgp_ip : null
          private_site_ip = var.bgp_enabled ? var.azure_secondary_bgp_ip : null
          psk             = var.secondary_connection_shared_key == null ? random_password.shared_key_secondary[0].result : var.secondary_connection_shared_key
          last_mile_bw = {
            downstream = var.downstream_bw
            upstream   = var.upstream_bw
          }
        }
      ]
    } : null
  }
}

# Configure the BGP peering for the primary VPN Gateway instance.
resource "cato_bgp_peer" "primary" {
  count                    = var.bgp_enabled ? 1 : 0
  site_id                  = cato_ipsec_site.ipsec_site.id
  name                     = var.cato_primary_bgp_peer_name
  cato_asn                 = var.cato_asn
  peer_asn                 = var.azure_asn
  peer_ip                  = var.azure_primary_bgp_ip
  metric                   = var.cato_primary_bgp_metric
  default_action           = var.cato_primary_bgp_default_action
  advertise_all_routes     = var.cato_primary_bgp_advertise_all_routes
  advertise_default_route  = var.cato_primary_bgp_advertise_default_route
  advertise_summary_routes = var.cato_primary_bgp_advertise_summary_route
  md5_auth_key             = var.cato_bgp_md5_auth_key

  bfd_settings = var.cato_bfd_enabled ? {
    transmit_interval = var.cato_primary_bgp_bfd_transmit_interval
    receive_interval  = var.cato_primary_bgp_bfd_receive_interval
    multiplier        = var.cato_primary_bgp_bfd_multiplier
  } : null

  lifecycle {
    ignore_changes = [summary_route]
  }
}

# Configure the BGP peering for the secondary VPN Gateway instance.
resource "cato_bgp_peer" "secondary" {
  count                    = var.bgp_enabled && var.secondary_cato_pop_ip != null ? 1 : 0
  site_id                  = cato_ipsec_site.ipsec_site.id
  name                     = var.cato_secondary_bgp_peer_name
  cato_asn                 = var.cato_asn
  peer_asn                 = var.azure_asn
  peer_ip                  = var.azure_secondary_bgp_ip
  metric                   = var.cato_secondary_bgp_metric
  default_action           = var.cato_secondary_bgp_default_action
  advertise_all_routes     = var.cato_secondary_bgp_advertise_all_routes
  advertise_default_route  = var.cato_secondary_bgp_advertise_default_route
  advertise_summary_routes = var.cato_secondary_bgp_advertise_summary_route
  md5_auth_key             = var.cato_bgp_md5_auth_key

  bfd_settings = var.cato_bfd_enabled ? {
    transmit_interval = var.cato_secondary_bgp_bfd_transmit_interval
    receive_interval  = var.cato_secondary_bgp_bfd_receive_interval
    multiplier        = var.cato_secondary_bgp_bfd_multiplier
  } : null

  lifecycle {
    ignore_changes = [summary_route]
  }
}

# --- API Calls to Update Site Details ---

# This resource runs when BGP is ENABLED to update the IKEv2 parameters.
resource "terraform_data" "update_ipsec_site_details_bgp" {
  depends_on = [cato_ipsec_site.ipsec_site]
  count      = var.enable_ipsec_site_update && var.bgp_enabled ? 1 : 0

  triggers_replace = [
    cato_ipsec_site.ipsec_site.id,
    var.cato_authMessage_integrity,
    var.cato_authMessage_cipher,
    var.cato_authMessage_dhGroup,
    var.cato_initMessage_prf,
    var.cato_initMessage_integrity,
    var.cato_initMessage_cipher,
    var.cato_initMessage_dhGroup,
    var.cato_connectionMode
  ]

  provisioner "local-exec" {
    command = <<EOT
cat <<'PAYLOAD' | curl -v -s -k -X POST -H 'Accept: application/json' -H 'Content-Type: application/json' -H 'x-API-Key: ${var.cato_api_token}' '${var.cato_baseurl}' --data @-
${templatefile("${path.module}/templates/update_site_payload.json.tftpl", {
    account_id      = var.cato_account_id
    site_id         = cato_ipsec_site.ipsec_site.id
    connection_mode = var.cato_connectionMode
    init_dh_group   = var.cato_initMessage_dhGroup
    init_cipher     = var.cato_initMessage_cipher
    init_integrity  = var.cato_initMessage_integrity
    init_prf        = var.cato_initMessage_prf
    auth_dh_group   = var.cato_authMessage_dhGroup
    auth_cipher     = var.cato_authMessage_cipher
    auth_integrity  = var.cato_authMessage_integrity
})}
PAYLOAD
EOT
}
}

# This resource runs when BGP is DISABLED to update IKEv2 and set static network ranges.
resource "terraform_data" "update_ipsec_site_details_nobgp" {
  depends_on = [cato_ipsec_site.ipsec_site]
  count      = var.enable_ipsec_site_update && !var.bgp_enabled ? 1 : 0

  triggers_replace = [
    cato_ipsec_site.ipsec_site.id,
    var.cato_authMessage_integrity,
    var.cato_authMessage_cipher,
    var.cato_authMessage_dhGroup,
    var.cato_initMessage_prf,
    var.cato_initMessage_integrity,
    var.cato_initMessage_cipher,
    var.cato_initMessage_dhGroup,
    var.cato_connectionMode,
    var.peer_networks
  ]

  provisioner "local-exec" {
    command = <<EOT
cat <<'PAYLOAD' | curl -v -s -k -X POST -H 'Accept: application/json' -H 'Content-Type: application/json' -H 'x-API-Key: ${var.cato_api_token}' '${var.cato_baseurl}' --data @-
${templatefile("${path.module}/templates/update_site_payload_nobgp.json.tftpl", {
    account_id          = var.cato_account_id
    site_id             = cato_ipsec_site.ipsec_site.id
    connection_mode     = var.cato_connectionMode
    network_ranges_json = jsonencode(var.peer_networks)
    init_dh_group       = var.cato_initMessage_dhGroup
    init_cipher         = var.cato_initMessage_cipher
    init_integrity      = var.cato_initMessage_integrity
    init_prf            = var.cato_initMessage_prf
    auth_dh_group       = var.cato_authMessage_dhGroup
    auth_cipher         = var.cato_authMessage_cipher
    auth_integrity      = var.cato_authMessage_integrity
})}
PAYLOAD
EOT
}
}
