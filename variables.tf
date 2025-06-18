
variable "cato_api_token" {
  description = "The API token for the Cato Management Application."
  type        = string
  sensitive   = true
}

variable "cato_account_id" {
  description = "The Account ID for the Cato Management Application."
  type        = string
}

variable "cato_baseurl" {
  description = "The base URL for the Cato API."
  type        = string
  default     = "https://api.catonetworks.com/api/v1/graphql"
}

variable "azure_resource_group_name" {
  description = "The name of the existing Azure Resource Group where the VWAN Hub resides."
  type        = string
}

variable "azure_vwan_name" {
  description = "The name of the existing Azure Virtual WAN."
  type        = string
}

variable "azure_hub_name" {
  description = "The name of the existing Azure Virtual Hub."
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to all taggable Azure resources."
  type        = map(string)
  default     = {}
}

variable "primary_cato_pop_ip" {
  description = "The public IP address of the primary Cato PoP. Must match the name of an allocated IP in Cato."
  type        = string
   validation {
    condition     = can(regex("^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", var.primary_cato_pop_ip))
    error_message = "The primary_cato_pop_ip value must be a valid IPv4 address."
  }
}

variable "secondary_cato_pop_ip" {
  description = "The public IP address of the secondary Cato PoP. Must match the name of an allocated IP in Cato. If null, a secondary connection will not be configured."
  type        = string
  default     = null
   validation {
    condition     = can(regex("^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", var.secondary_cato_pop_ip))
    error_message = "The primary_cato_pop_ip value must be a valid IPv4 address."
  }
}

variable "custom_vpn_gateway_name" {
  description = "Optional custom name for the Azure VPN Gateway. If not provided, a name will be generated based on the site_name."
  type        = string
  default     = null
}

variable "custom_vpn_site_name" {
  description = "Optional custom name for the Azure VPN Site. If not provided, a name will be generated based on the site_name."
  type        = string
  default     = null
}

variable "custom_vpn_gateway_connection_name" {
  description = "Optional custom name for the Azure VPN Gateway Connection. If not provided, a name will be generated based on the site_name."
  type        = string
  default     = null
}

variable "vpn_site_primary_link_name" {
  description = "The name for the primary link on the Azure VPN Site."
  type        = string
  default     = "PrimaryLink"
}

variable "vpn_site_secondary_link_name" {
  description = "The name for the secondary link on the Azure VPN Site."
  type        = string
  default     = "SecondaryLink"
}

variable "downstream_bw" {
  description = "The downstream bandwidth in Mbps."
  type        = number
  default     = 1000
}

variable "upstream_bw" {
  description = "The upstream bandwidth in Mbps."
  type        = number
  default     = 1000
}

variable "cato_asn" {
  description = "The BGP ASN for Cato."
  type        = number
}

variable "azure_asn" {
  description = "The BGP ASN for the Azure VPN Gateway."
  type        = number
  default     = 65515
}

variable "azure_bgp_peer_weight" {
  description = "The BGP peer weight for the Azure VPN Gateway."
  type        = number
  default     = 0
}

variable "azure_primary_bgp_ip" {
  description = "The BGP peering IP address for the primary Azure VPN Gateway instance. Must be in the same /30 or /31 subnet as the corresponding cato_primary_bgp_ip."
  type        = string
  validation {
    condition     = can(regex("^169\\.254\\.(21|22)\\.((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))$", var.azure_primary_bgp_ip))
    error_message = "The bgp_ip must be a valid IP address in the range 169.254.21.0 - 169.254.22.255."
  }
}

variable "cato_primary_bgp_ip" {
  description = "The BGP peering IP address for the primary Cato link. Must be in the same /30 or /31 subnet as the corresponding azure_primary_bgp_ip."
  type        = string
  validation {
    condition     = can(regex("^169\\.254\\.(21|22)\\.((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))$", var.cato_primary_bgp_ip))
    error_message = "The bgp_ip must be a valid IP address in the range 169.254.21.0 - 169.254.22.255."
  }
}

variable "azure_secondary_bgp_ip" {
  description = "The BGP peering IP address for the secondary Azure VPN Gateway instance. Required if secondary_cato_pop_ip is not null."
  type        = string
  default     = null
  validation {
    condition     = can(regex("^169\\.254\\.(21|22)\\.((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))$", var.azure_secondary_bgp_ip))
    error_message = "The bgp_ip must be a valid IP address in the range 169.254.21.0 - 169.254.22.255."
  }
}

variable "cato_secondary_bgp_ip" {
  description = "The BGP peering IP address for the secondary Cato link. Required if secondary_cato_pop_ip is not null."
  type        = string
  default     = null
  validation {
    condition     = can(regex("^169\\.254\\.(21|22)\\.((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))$", var.cato_secondary_bgp_ip))
    error_message = "The bgp_ip must be a valid IP address in the range 169.254.21.0 - 169.254.22.255."
  }
}

variable "cato_site_address_cidrs" {
  description = "A list of address CIDRs for the Azure VPN Site resource."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ipsec_sa_lifetime_sec" {
  description = "The IPSec Security Association lifetime in seconds for the site-to-site VPN tunnel."
  type        = number
  default     = 19800
}

variable "ipsec_sa_data_size_kb" {
  description = "The IPSec Security Association payload size in KB for the site-to-site VPN tunnel."
  type        = number
  default     = 102400000
}


# --- BGP Peer Variables ---

variable "bgp_enabled" {
  description = "Controls BGP settings. If true, BGP peers are created and routes are propagated dynamically. If false, static routes must be provided via the 'peer_networks' variable."
  type        = bool
  default     = true
}

variable "cato_primary_bgp_peer_name" {
  description = "Name for the primary BGP peer in Cato."
  type        = string
  default     = "Azure-Primary-BGP-Peer"
}

variable "cato_secondary_bgp_peer_name" {
  description = "Name for the secondary BGP peer in Cato."
  type        = string
  default     = "Azure-Secondary-BGP-Peer"
}

variable "cato_primary_bgp_metric" {
  description = "The BGP metric for the primary peer."
  type        = number
  default     = 100
}

variable "cato_secondary_bgp_metric" {
  description = "The BGP metric for the secondary peer."
  type        = number
  default     = 200
}

variable "cato_primary_bgp_default_action" {
  description = "The default action for the primary BGP peer, can be ACCEPT or REJECT."
  type        = string
  default     = "ACCEPT"
  validation {
    condition     = contains(["ACCEPT", "REJECT"], var.cato_primary_bgp_default_action)
    error_message = "The BGP default action must be either 'ACCEPT' or 'REJECT'."
  }
}

variable "cato_secondary_bgp_default_action" {
  description = "The default action for the secondary BGP peer, can be ACCEPT or REJECT."
  type        = string
  default     = "ACCEPT"
  validation {
    condition     = contains(["ACCEPT", "REJECT"], var.cato_secondary_bgp_default_action)
    error_message = "The BGP default action must be either 'ACCEPT' or 'REJECT'."
  }
}

variable "cato_primary_bgp_advertise_all_routes" {
  description = "Advertise all routes from Cato to the primary peer."
  type        = bool
  default     = true
}

variable "cato_secondary_bgp_advertise_all_routes" {
  description = "Advertise all routes from Cato to the secondary peer."
  type        = bool
  default     = true
}

variable "cato_primary_bgp_advertise_default_route" {
  description = "Advertise the default route from Cato to the primary peer."
  type        = bool
  default     = false
}

variable "cato_secondary_bgp_advertise_default_route" {
  description = "Advertise the default route from Cato to the secondary peer."
  type        = bool
  default     = false
}

variable "cato_primary_bgp_advertise_summary_route" {
  description = "Advertise summary routes from Cato to the primary peer."
  type        = bool
  default     = false
}

variable "cato_secondary_bgp_advertise_summary_route" {
  description = "Advertise summary routes from Cato to the secondary peer."
  type        = bool
  default     = false
}

variable "cato_bgp_md5_auth_key" {
  description = "The MD5 authentication key for BGP peering. If null, MD5 auth is disabled."
  type        = string
  sensitive   = true
  default = ""
}

# --- BFD Variables ---

variable "cato_bfd_enabled" {
  description = "Enable or disable BFD on the Cato BGP peer. This should only be enabled if BGP is also enabled."
  type        = bool
  default     = true
}

variable "cato_primary_bgp_bfd_transmit_interval" {
  description = "The BFD transmit interval in milliseconds for the primary peer. The recommended default for internet-based connections is 1000ms."
  type        = number
  default     = 1000
}

variable "cato_primary_bgp_bfd_receive_interval" {
  description = "The BFD receive interval in milliseconds for the primary peer. The recommended default for internet-based connections is 1000ms."
  type        = number
  default     = 1000
}

variable "cato_primary_bgp_bfd_multiplier" {
  description = "The BFD multiplier for the primary peer, which determines the detection time. The recommended default for internet-based connections is 5."
  type        = number
  default     = 5
}

variable "cato_secondary_bgp_bfd_transmit_interval" {
  description = "The BFD transmit interval in milliseconds for the secondary peer. The recommended default for internet-based connections is 1000ms."
  type        = number
  default     = 1000
}

variable "cato_secondary_bgp_bfd_receive_interval" {
  description = "The BFD receive interval in milliseconds for the secondary peer. The recommended default for internet-based connections is 1000ms."
  type        = number
  default     = 1000
}

variable "cato_secondary_bgp_bfd_multiplier" {
  description = "The BFD multiplier for the secondary peer, which determines the detection time. The recommended default for internet-based connections is 5."
  type        = number
  default     = 5
}

variable "peer_networks" {
  description = <<EOF
  (Optional) List of Networks on the Azure side (if BGP is disabled)
  Examples: 
  ["servers:10.0.0.0/24","devices:10.1.0.0/24"]
  EOF
  type        = list(string)
  default     = null
}

variable "cato_local_networks" {
  description = <<EOF
  If we aren't using BGP, we will need a list of CIDRs which live behind Cato
  for more information [https://support.catonetworks.com/hc/en-us/articles/14110195123485-Working-with-the-Cato-System-Range](https://support.catonetworks.com/hc/en-us/articles/14110195123485-Working-with-the-Cato-System-Range)
  Default: ["10.41.0.0/16", "10.254.254.0/24"] 
  EOF

  type = list(string)
  default = [
    "10.41.0.0/16",   #Cato VPN Client 
    "10.254.254.0/24" #Cato System Range [https://support.catonetworks.com/hc/en-us/articles/14110195123485-Working-with-the-Cato-System-Range](https://support.catonetworks.com/hc/en-us/articles/14110195123485-Working-with-the-Cato-System-Range)
  ]
}

variable "site_name" {
  description = "The name of the site in the Cato Management Application."
  type        = string
}

variable "site_description" {
  description = "A description for the site in the Cato Management Application."
  type        = string
  default     = "Azure VWAN Hub Connection"
}

variable "site_type" {
  description = "The type of the site in Cato (e.g., CLOUD_DC)."
  type        = string
  default     = "CLOUD_DC"
}

variable "native_network_range" {
  description = "The native network range for the site. If null, it will be automatically populated from the Azure Hub's address prefix."
  type        = string
  default     = null
}

variable "site_location" {
  description = "An object representing the site's physical location."
  type = object({
    city         = string
    country_code = string
    state_code   = string
    timezone     = string
  })
  default = {
    city         = "Ashburn"
    country_code = "US"
    state_code   = "VA"
    timezone     = "America/New_York"
  }
}

variable "primary_connection_shared_key" {
  description = "The pre-shared key for the primary connection. If null, a random one will be generated."
  type        = string
  sensitive   = true
  default = null
}

variable "secondary_connection_shared_key" {
  description = "The pre-shared key for the secondary connection. If null, a random one will be generated."
  type        = string
  sensitive   = true
  default = null
}

variable "enable_ipsec_site_update" {
  description = "If true, the terraform_data resource will run to update the IPsec site details via API."
  type        = bool
  default     = true
}

# --- Azure IPsec Policy Variables ---

variable "azure_ipsec_dh_group" {
  description = "The DH Group used in IKE Phase 1 for initial SA on the Azure side."
  type        = string
  default     = "DHGroup14"
  validation {
    condition     = contains(["None", "DHGroup1", "DHGroup2", "DHGroup14", "DHGroup24", "DHGroup2048", "ECP256", "ECP384"], var.azure_ipsec_dh_group)
    error_message = "Invalid value for Azure DH Group."
  }
}

variable "azure_ipsec_ike_encryption" {
  description = "The IKE encryption algorithm (IKE phase 2) on the Azure side."
  type        = string
  default     = "GCMAES256"
  validation {
    condition     = contains(["DES", "DES3", "AES128", "AES192", "AES256", "GCMAES128", "GCMAES256"], var.azure_ipsec_ike_encryption)
    error_message = "Invalid value for Azure IKE Encryption Algorithm."
  }
}

variable "azure_ipsec_ike_integrity" {
  description = "The IKE integrity algorithm (IKE phase 2) on the Azure side. For GCMAES ciphers, this must match the cipher."
  type        = string
  default     = "SHA256"
  validation {
    condition     = contains(["MD5", "SHA1", "SHA256", "SHA384", "GCMAES128", "GCMAES256"], var.azure_ipsec_ike_integrity)
    error_message = "Invalid value for Azure IKE Integrity Algorithm."
  }
}

variable "azure_ipsec_encryption" {
  description = "The IPSec encryption algorithm (IKE phase 1) on the Azure side."
  type        = string
  default     = "GCMAES256"
  validation {
    condition     = contains(["AES128", "AES192", "AES256", "DES", "DES3", "GCMAES128", "GCMAES192", "GCMAES256", "None"], var.azure_ipsec_encryption)
    error_message = "Invalid value for Azure IPSec Encryption Algorithm."
  }
}

variable "azure_ipsec_integrity" {
  description = "The IPSec integrity algorithm (IKE phase 1) on the Azure side. For GCMAES ciphers, this must match the cipher."
  type        = string
  default     = "GCMAES256"
  validation {
    condition     = contains(["MD5", "SHA1", "SHA256", "GCMAES128", "GCMAES192", "GCMAES256"], var.azure_ipsec_integrity)
    error_message = "Invalid value for Azure IPSec Integrity Algorithm."
  }
}

variable "azure_ipsec_pfs_group" {
  description = "The Pfs Group used in IKE Phase 2 for the new child SA on the Azure side."
  type        = string
  default     = "PFS14"
  validation {
    condition     = contains(["None", "PFS1", "PFS2", "PFS14", "PFS24", "PFS2048", "PFSMM", "ECP256", "ECP384"], var.azure_ipsec_pfs_group)
    error_message = "Invalid value for Azure PFS Group."
  }
}


# --- Cato IKEv2 Customization Variables ---

variable "cato_connectionMode" {
  description = <<EOF
  Cato Connection Mode.  Determines the protocol for establishing the Security Association (SA) Tunnel. 
  Valid values are: Responder-Only Mode: Cato Cloud only responds to incoming requests by the initiator (e.g. a Firewall device) to establish a security association. 
  Bidirectional Mode: Both Cato Cloud and the peer device on customer site can initiate the IPSec SA establishment.  
  Valid Options are: 
    BIDIRECTIONAL
    RESPONDER_ONLY
    Default to BIDIRECTIONAL
    EOF
  type        = string
  default     = "BIDIRECTIONAL"
  validation {
    condition     = contains(["BIDIRECTIONAL", "RESPONDER_ONLY"], var.cato_connectionMode)
    error_message = "The connection mode must be either 'BIDIRECTIONAL' or 'RESPONDER_ONLY'."
  }
}

variable "cato_identificationType" {
  description = <<EOF
  Cato Identification Type.  The authentication identification type used for SA authentication. When using “BIDIRECTIONAL”, it is set to “IPv4” by default. 
  Other methods are available in Responder mode only. 
  Valid Options are: 
    EMAIL
    FQDN
    IPV4
    KEY_ID
    Default to IPV4
    EOF
  type        = string
  default     = "IPV4"
  validation {
    condition     = contains(["EMAIL", "FQDN", "IPV4", "KEY_ID"], var.cato_identificationType)
    error_message = "The identification type must be one of 'EMAIL', 'FQDN', 'IPV4', or 'KEY_ID'."
  }
}

variable "cato_initMessage_dhGroup" {
  description = <<EOF
   Cato Phase 1 DHGroup.  The Diffie-Hellman Group. The first number is the DH-group number, and the second number is 
   the corresponding prime modulus size in bits
   Valid Options are: 
    AUTOMATIC, DH_14_MODP2048, DH_15_MODP3072, DH_16_MODP4096, DH_19_ECP256,
    DH_2_MODP1024, DH_20_ECP384, DH_21_ECP521, DH_5_MODP1536, NONE
    EOF
  type        = string
  default     = "DH_14_MODP2048"
  validation {
    condition = contains([
      "AUTOMATIC", "DH_14_MODP2048", "DH_15_MODP3072", "DH_16_MODP4096", "DH_19_ECP256",
      "DH_2_MODP1024", "DH_20_ECP384", "DH_21_ECP521", "DH_5_MODP1536", "NONE"
    ], var.cato_initMessage_dhGroup)
    error_message = "Invalid value for Phase 1 DH Group."
  }
}

variable "cato_initMessage_cipher" {
  description = <<EOF
  Cato Phase 1 ciphers.  The SA tunnel encryption method. 
  Note: For sites with bandwidth > 100Mbps, use only AES_GCM_128 or AES_GCM_256. For bandwidth < 100Mbps, use AES_CBC algorithms.
  Valid options are: 
    AES_CBC_128, AES_CBC_256, AES_GCM_128, AES_GCM_256, AUTOMATIC, DES3_CBC, NONE
    EOF
  type        = string
  default     = "AES_GCM_256"
  validation {
    condition = contains([
      "AES_CBC_128", "AES_CBC_256", "AES_GCM_128", "AES_GCM_256", "AUTOMATIC", "DES3_CBC", "NONE"
    ], var.cato_initMessage_cipher)
    error_message = "Invalid value for Phase 1 Cipher."
  }
}

variable "cato_initMessage_integrity" {
  description = <<EOF
  Cato Phase 1 Hashing Algorithm.  The algorithm used to verify the integrity and authenticity of IPsec packets
   Valid Options are: 
    AUTOMATIC, MD5, NONE, SHA1, SHA256, SHA384, SHA512
    Default to AUTOMATIC
    EOF
  type        = string
  default     = "AUTOMATIC"
  validation {
    condition = contains([
      "AUTOMATIC", "MD5", "NONE", "SHA1", "SHA256", "SHA384", "SHA512"
    ], var.cato_initMessage_integrity)
    error_message = "Invalid value for Phase 1 Integrity Algorithm."
  }
}

variable "cato_initMessage_prf" {
  description = <<EOF
  Cato Phase 1 Hashing Algorithm for The Pseudo-random function (PRF) used to derive the cryptographic keys used in the SA establishment process. 
  Valid Options are: 
    AUTOMATIC, MD5, NONE, SHA1, SHA256, SHA384, SHA512
    Default to AUTOMATIC
    EOF
  type        = string
  default     = "SHA256"
  validation {
    condition = contains([
      "AUTOMATIC", "MD5", "NONE", "SHA1", "SHA256", "SHA384", "SHA512"
    ], var.cato_initMessage_prf)
    error_message = "Invalid value for Phase 1 PRF."
  }
}

variable "cato_authMessage_dhGroup" {
  description = <<EOF
   Cato Phase 2 DHGroup.  The Diffie-Hellman Group. The first number is the DH-group number, and the second number is 
   the corresponding prime modulus size in bits
   Valid Options are: 
    AUTOMATIC, DH_14_MODP2048, DH_15_MODP3072, DH_16_MODP4096, DH_19_ECP256,
    DH_2_MODP1024, DH_20_ECP384, DH_21_ECP521, DH_5_MODP1536, NONE
    EOF
  type        = string
  default     = "DH_14_MODP2048"
  validation {
    condition = contains([
      "AUTOMATIC", "DH_14_MODP2048", "DH_15_MODP3072", "DH_16_MODP4096", "DH_19_ECP256",
      "DH_2_MODP1024", "DH_20_ECP384", "DH_21_ECP521", "DH_5_MODP1536", "NONE"
    ], var.cato_authMessage_dhGroup)
    error_message = "Invalid value for Phase 2 DH Group."
  }
}

variable "cato_authMessage_cipher" {
  description = <<EOF
  Cato Phase 2 ciphers.  The SA tunnel encryption method.
  Note: For sites with bandwidth > 100Mbps, use only AES_GCM_128 or AES_GCM_256. For bandwidth < 100Mbps, use AES_CBC algorithms.
  Valid options are: 
    AES_CBC_128, AES_CBC_256, AES_GCM_128, AES_GCM_256, AUTOMATIC, DES3_CBC, NONE
    EOF
  type        = string
  default     = "AES_GCM_256"
  validation {
    condition = contains([
      "AES_CBC_128", "AES_CBC_256", "AES_GCM_128", "AES_GCM_256", "AUTOMATIC", "DES3_CBC", "NONE"
    ], var.cato_authMessage_cipher)
    error_message = "Invalid value for Phase 2 Cipher."
  }
}

variable "cato_authMessage_integrity" {
  description = <<EOF
  Cato Phase 2 Hashing Algorithm. The algorithm used to verify the integrity and authenticity of IPsec packets.
  Note: Azure requires SHA256 or SHA384 for IKE Phase 2 integrity.
  Valid Options are: 
    AUTOMATIC
    MD5
    NONE
    SHA1
    SHA256
    SHA384
    SHA512
    EOF
  type        = string
  default     = "AUTOMATIC"
  validation {
    condition     = contains(["SHA256", "SHA384", "AUTOMATIC"], var.cato_authMessage_integrity)
    error_message = "Invalid value for Phase 2 Integrity Algorithm. Must be SHA256 or SHA384."
  }
}