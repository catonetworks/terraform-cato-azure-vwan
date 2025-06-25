output "azure_vpn_gateway_id" {
  description = "The resource ID of the Azure VPN Gateway."
  value       = azurerm_vpn_gateway.cato_vpn_gateway.id
}

output "azure_vpn_gateway_connection_id" {
  description = "The resource ID of the Azure VPN Gateway Connection."
  value       = azurerm_vpn_gateway_connection.cato_vpn_gateway_connection.id
}

output "azure_vpn_site_id" {
  description = "The resource ID of the Azure VPN Site."
  value       = azurerm_vpn_site.cato_vpn_site.id
}

output "azure_primary_public_ip" {
  description = "The public IP address of the primary instance of the Azure VPN Gateway."
  value       = local.azure_primary_public_ip
}

output "azure_secondary_public_ip" {
  description = "The public IP address of the secondary instance of the Azure VPN Gateway. This will be an empty string if a secondary connection is not configured."
  value       = var.secondary_cato_pop_ip != null ? local.azure_secondary_public_ip : ""
}

output "azure_vpn_gateway_bgp_settings" {
  description = "The BGP settings of the Azure VPN Gateway that was created."
  value       = azurerm_vpn_gateway.cato_vpn_gateway.bgp_settings
}

output "azure_vpn_gateway_ip_configuration" {
  description = "The IP configuration of the Azure VPN Gateway that was created."
  value       = azurerm_vpn_gateway.cato_vpn_gateway.ip_configuration
}

output "azure_vpn_gateway_settings" {
  description = "The settings of the Azure VPN Gateway that was created."
  value       = local.vpn_gateway_properties
}

output "cato_ipsec_site_id" {
  description = "The ID of the Cato IPsec site that was created."
  value       = cato_ipsec_site.ipsec_site.id
}

output "cato_ipsec_site_name" {
  description = "The name of the Cato IPsec site that was created."
  value       = cato_ipsec_site.ipsec_site.name
}

output "cato_primary_pop_ip" {
  description = "The IP address of the primary Cato PoP that was configured."
  value       = var.primary_cato_pop_ip
}

output "cato_secondary_pop_ip" {
  description = "The IP address of the secondary Cato PoP that was configured. This will be an empty string if a secondary connection is not configured."
  value       = var.secondary_cato_pop_ip != null ? var.secondary_cato_pop_ip : ""
}

output "primary_preshared_key" {
  description = "The pre-shared key used for the primary VPN connection. This will be the generated key if one was not provided."
  value       = var.primary_connection_shared_key == null ? random_password.shared_key_primary[0].result : var.primary_connection_shared_key
  sensitive   = true
}

output "secondary_preshared_key" {
  description = "The pre-shared key used for the secondary VPN connection. This will be the generated key if one was not provided."
  value       = var.secondary_cato_pop_ip != null && var.secondary_connection_shared_key == null ? random_password.shared_key_secondary[0].result : var.secondary_connection_shared_key
  sensitive   = true
}
