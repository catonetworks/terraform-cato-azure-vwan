variable "cato_baseurl" {
  description = "Cato API base URL"
  type        = string
  default     = "https://api.catonetworks.com/api/v1/graphql2"
}

variable "cato_token" {
  description = "Cato API token"
  type        = string
}

variable "cato_account_id" {
  description = "Cato account ID"
  type        = number
}


variable "azure_subscription_id" {
  description = "Azure subscription ID, example: abcde12345-abcd-1234-abcd-abcde12345"
  type        = string
}

variable "azure_vwan_hub_id" {
  description = "Azure vWAN Hub ID, example: /subscriptions/abcde12345-abcd-1234-abcd-abcde12345/resourceGroups/YOUR_RESOURCE_GROUP_NAME/providers/Microsoft.Network/virtualHubs/YOUR_VIRTUAL_HUB_NAME"
  type        = string
}


variable "site_name" {
  description = "Name of the Cato site"
  type        = string
}

variable "cato_site_address_cidrs" {
  description = "Address CIDRs of the VPN Site"
  type        = list(string)
}

variable "connection_bandwidth" {
  description = "VPN connection bandwidth (Mbps)"
  type        = number
  default     = 10
}

variable "vpn_site_primary_link_name" {
  type    = string
  default = "Primary site link name, example: VPN_vWAN2_Cato_Primary"
}

variable "vpn_site_secondary_link_name" {
  type    = string
  default = "Secondary site link name, example: VPN_vWAN2_Cato_Secondary"
}

variable "site_description" {
  description = "Description of the IPSec site"
  type        = string
  default     = "vWAN Hub description"
}

variable "site_location" {
  type = object({
    city         = string
    country_code = string
    state_code   = string
    timezone     = string
  })
}

variable "cato_primary_public_ip" {
  description = "Cato primary public IP"
  type        = string
}

variable "cato_secondary_public_ip" {
  description = "Cato secondary public IP"
  type        = string
}

variable "bgp_enabled" {
  description = "BGP enabled"
  type        = bool
}

variable "cato_asn" {
  description = "Cato ASN"
  type        = number
}

variable "cato_primary_peering_address" {
  description = "Cato BGP peering IP address"
  type        = string
}

variable "cato_secondary_peering_address" {
  description = "Cato BGP peering IP address"
  type        = string
}

variable "vpn_gateway_connection_name" {
  description = "Azure VPN gateway connection name"
  type        = string
  default     = "vpn-gateway-connection-cato"
}

variable "vpn_gateway_name" {
  description = "Azure VPN gateway name"
  type        = string
  default     = "vpn-gateway-cato"
}

variable "vpn_site_name" {
  description = "Azure VPN site name"
  type        = string
  default     = "vpn-site-cato"
}

