
# Look up the existing Resource Group. This is a mandatory prerequisite.
data "azurerm_resource_group" "rg" {
  name = var.azure_resource_group_name
}

# Look up the existing Virtual WAN. This is a mandatory prerequisite.
data "azurerm_virtual_wan" "vwan" {
  name                = var.azure_vwan_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

# Look up the existing Virtual Hub. This is a mandatory prerequisite.
data "azurerm_virtual_hub" "hub" {
  name                = var.azure_hub_name
  resource_group_name = data.azurerm_resource_group.rg.name
}


# Fetch the specific primary Cato allocated IP.
data "cato_allocatedIp" "primary" {
  count       = var.primary_cato_pop_ip != null ? 1 : 0
  name_filter = [var.primary_cato_pop_ip]
}

# Fetch the specific secondary Cato allocated IP.
data "cato_allocatedIp" "secondary" {
  count       = var.secondary_cato_pop_ip != null ? 1 : 0
  name_filter = [var.secondary_cato_pop_ip]
}

# Use the azapi provider to get the full details of the VPN gateway,
# including the instance public IPs which are not exposed in the azurerm provider.
data "azapi_resource" "vpn_gateway_details" {
  type        = "Microsoft.Network/vpnGateways@2023-04-01"
  resource_id = azurerm_vpn_gateway.cato_vpn_gateway.id

  # This ensures the data source is read only after the gateway is fully provisioned.
  depends_on = [azurerm_vpn_gateway_connection.cato_vpn_gateway_connection]
}