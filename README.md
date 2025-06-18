# CATO IPSec Azure vWAN Terraform Module
This Terraform module provisions an IPSec connection between CATO Cloud and Azure vWAN. It creates primary and secondary tunnels for high availability (HA) and establishes a BGP connection to enable dynamic routing.

### Note: 
This module requires that vWAN and a vWAN Hub has already been setup and is ready for use.  For more information on building the required resources, see the "Creating Azure Resource Dependencies" section below.


<details>
<summary>Creating Azure Resource Dependencies - Example</summary>

## Creating Azure Resource Dependencies

The Cato vWAN relies on an [Azure Resource Group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group), [Azure Virtual WAN](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_wan) and [Azure Virtual Hub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_hub) to be created in advance. 

```hcl
# Create Azure Resources
resource "azurerm_resource_group" "azure-rg" {
  location = "US East"
  name     = "Azure_vWAN_RG"
}

resource "azurerm_virtual_wan" "virtualwan" {
  name                = "Azure_vWAN-virtualwan"
  resource_group_name = azurerm_resource_group.azure-rg.name
  location            = azurerm_resource_group.azure-rg.location
}

resource "azurerm_virtual_hub" "virtualhub" {
  name                = "Azure_vWAN-virtualhub"
  resource_group_name = azurerm_resource_group.azure-rg.name
  location            = azurerm_resource_group.azure-rg.location
  virtual_wan_id      = azurerm_virtual_wan.virtualwan.id
  address_prefix      = "10.4.0.0/16"
}

```
</details>

## Usage

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.1.0"
    }
    cato = {
      source  = "CatoNetworks/cato"
      version = "~> 0.0.24"
    }
    random = {
      source = "hashicorp/random"
    }
    azapi = {
      source  = "Azure/azapi"
      version = ">= 1.5"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
}

provider "cato" {
  baseurl    = var.baseurl
  token      = var.cato_token
  account_id = var.cato_account_id
}

variable "baseurl" {
  description = "Cato Management API Base URL."
  type        = string
}

variable "cato_token" {
  description = "Cato Management API Token."
  type        = string
  # sensitive   = true
}

variable "cato_account_id" {
  description = "Your Cato Account ID."
  type        = string
}

variable "azure_subscription_id" {
  description = "The Azure Subscription ID where resources will be deployed."
  type        = string
  default     = "xxxxxxxx-xxxx-xxxx-xxxxxxxxxxxx"
}

module "cato_azure_vwan_connection" {
  source = "catonetworks/azure-vwan/cato"

  # --- Provider and Authentication Variables ---
  cato_api_token  = var.cato_token
  cato_account_id = var.cato_account_id
  cato_baseurl    = var.baseurl
  # azure_subscription_id = var.azure_subscription_id

  # --- Azure Naming and Location Variables ---
  azure_resource_group_name = "networking-rg"
  azure_vwan_name           = "my-azure-vwan"
  azure_hub_name            = "my-azure-vwan-hub"

  # --- Cato Site Configuration ---
  site_name            = "Azure-VWAN-Hub-Site"
  site_description     = "Connection to Azure VWAN Hub in East US"
  site_type            = "CLOUD_DC"
  native_network_range = null # Let the module discover it from the hub
  site_location = {
    city         = "Ashburn"
    country_code = "US"
    state_code   = "US-VA"
    timezone     = "America/New_York"
  }
  primary_cato_pop_ip   = "x.x.x.x" # Name of your primary allocated IP
  secondary_cato_pop_ip = "y.y.y.y" # Name of your secondary allocated IP (or null)

  # --- Networking and BGP Variables ---
  cato_asn              = 65000 #Private ASN for Cato Side
  azure_asn             = 65515 #Private ASN for Azure Side
  azure_bgp_peer_weight = 10

  # --- BGP IP Configuration ---
  azure_primary_bgp_ip   = "169.254.21.1"
  cato_primary_bgp_ip    = "169.254.21.2"
  azure_secondary_bgp_ip = "169.254.22.1"
  cato_secondary_bgp_ip  = "169.254.22.2"

  # --- Bandwidth ---
  downstream_bw = 1000
  upstream_bw   = 1000

  # --- Tagging ---
  tags = {
    Environment = "Production"
    Owner       = "NetworkingTeam"
    Project     = "Cato-VWAN-Integration"
    Terraform   = "true"
  }
}
```


## Requirements
This terraform module requires:
- Two [Allocated IPs in CATO](https://support.catonetworks.com/hc/en-us/articles/4413273467153-Allocating-IP-Addresses-for-the-Account) Cloud
- A Cato Management Application [API Key](https://support.catonetworks.com/hc/en-us/articles/4413280536081-Generating-API-Keys-for-the-Cato-API)
- A configured vWAN and Hub (As notated above)

## Site Location Reference

For more information on site_location syntax, use the [Cato CLI](https://github.com/catonetworks/cato-cli) to lookup values.

```bash
$ pip3 install catocli
$ export CATO_TOKEN="your-api-token-here"
$ export CATO_ACCOUNT_ID="your-account-id"
$ catocli query siteLocation -h
$ catocli query siteLocation '{"filters":[{"search": "San Diego","field":"city","operation":"exact"}]}' -p
```


## Authors

Module is maintained by [Cato Networks](https://github.com/catonetworks) with help from [these awesome contributors](https://github.com/catonetworks/terraform-cato-ipsec-aws/graphs/contributors).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/catonetworks/terraform-cato-ipsec-aws/tree/master/LICENSE) for full details.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | >= 1.5 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.1.0 |
| <a name="requirement_cato"></a> [cato](#requirement\_cato) | ~> 0.0.24 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | >= 1.5 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.1.0 |
| <a name="provider_cato"></a> [cato](#provider\_cato) | ~> 0.0.24 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_vpn_gateway.cato_vpn_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/vpn_gateway) | resource |
| [azurerm_vpn_gateway_connection.cato_vpn_gateway_connection](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/vpn_gateway_connection) | resource |
| [azurerm_vpn_site.cato_vpn_site](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/vpn_site) | resource |
| [cato_bgp_peer.primary](https://registry.terraform.io/providers/CatoNetworks/cato/latest/docs/resources/bgp_peer) | resource |
| [cato_bgp_peer.secondary](https://registry.terraform.io/providers/CatoNetworks/cato/latest/docs/resources/bgp_peer) | resource |
| [cato_ipsec_site.ipsec_site](https://registry.terraform.io/providers/CatoNetworks/cato/latest/docs/resources/ipsec_site) | resource |
| [random_password.shared_key_primary](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.shared_key_secondary](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [terraform_data.update_ipsec_site_details_bgp](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.update_ipsec_site_details_nobgp](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [azapi_resource.vpn_gateway_details](https://registry.terraform.io/providers/Azure/azapi/latest/docs/data-sources/resource) | data source |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_virtual_hub.hub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_hub) | data source |
| [azurerm_virtual_wan.vwan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_wan) | data source |
| [cato_allocatedIp.primary](https://registry.terraform.io/providers/CatoNetworks/cato/latest/docs/data-sources/allocatedIp) | data source |
| [cato_allocatedIp.secondary](https://registry.terraform.io/providers/CatoNetworks/cato/latest/docs/data-sources/allocatedIp) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_asn"></a> [azure\_asn](#input\_azure\_asn) | The BGP ASN for the Azure VPN Gateway. | `number` | `65515` | no |
| <a name="input_azure_bgp_peer_weight"></a> [azure\_bgp\_peer\_weight](#input\_azure\_bgp\_peer\_weight) | The BGP peer weight for the Azure VPN Gateway. | `number` | `0` | no |
| <a name="input_azure_hub_name"></a> [azure\_hub\_name](#input\_azure\_hub\_name) | The name of the existing Azure Virtual Hub. | `string` | n/a | yes |
| <a name="input_azure_ipsec_dh_group"></a> [azure\_ipsec\_dh\_group](#input\_azure\_ipsec\_dh\_group) | The DH Group used in IKE Phase 1 for initial SA on the Azure side. | `string` | `"DHGroup14"` | no |
| <a name="input_azure_ipsec_encryption"></a> [azure\_ipsec\_encryption](#input\_azure\_ipsec\_encryption) | The IPSec encryption algorithm (IKE phase 1) on the Azure side. | `string` | `"GCMAES256"` | no |
| <a name="input_azure_ipsec_ike_encryption"></a> [azure\_ipsec\_ike\_encryption](#input\_azure\_ipsec\_ike\_encryption) | The IKE encryption algorithm (IKE phase 2) on the Azure side. | `string` | `"GCMAES256"` | no |
| <a name="input_azure_ipsec_ike_integrity"></a> [azure\_ipsec\_ike\_integrity](#input\_azure\_ipsec\_ike\_integrity) | The IKE integrity algorithm (IKE phase 2) on the Azure side. For GCMAES ciphers, this must match the cipher. | `string` | `"SHA256"` | no |
| <a name="input_azure_ipsec_integrity"></a> [azure\_ipsec\_integrity](#input\_azure\_ipsec\_integrity) | The IPSec integrity algorithm (IKE phase 1) on the Azure side. For GCMAES ciphers, this must match the cipher. | `string` | `"GCMAES256"` | no |
| <a name="input_azure_ipsec_pfs_group"></a> [azure\_ipsec\_pfs\_group](#input\_azure\_ipsec\_pfs\_group) | The Pfs Group used in IKE Phase 2 for the new child SA on the Azure side. | `string` | `"PFS14"` | no |
| <a name="input_azure_primary_bgp_ip"></a> [azure\_primary\_bgp\_ip](#input\_azure\_primary\_bgp\_ip) | The BGP peering IP address for the primary Azure VPN Gateway instance. Must be in the same /30 or /31 subnet as the corresponding cato\_primary\_bgp\_ip. | `string` | n/a | yes |
| <a name="input_azure_resource_group_name"></a> [azure\_resource\_group\_name](#input\_azure\_resource\_group\_name) | The name of the existing Azure Resource Group where the VWAN Hub resides. | `string` | n/a | yes |
| <a name="input_azure_secondary_bgp_ip"></a> [azure\_secondary\_bgp\_ip](#input\_azure\_secondary\_bgp\_ip) | The BGP peering IP address for the secondary Azure VPN Gateway instance. Required if secondary\_cato\_pop\_ip is not null. | `string` | `null` | no |
| <a name="input_azure_vwan_name"></a> [azure\_vwan\_name](#input\_azure\_vwan\_name) | The name of the existing Azure Virtual WAN. | `string` | n/a | yes |
| <a name="input_bgp_enabled"></a> [bgp\_enabled](#input\_bgp\_enabled) | Controls BGP settings. If true, BGP peers are created and routes are propagated dynamically. If false, static routes must be provided via the 'peer\_networks' variable. | `bool` | `true` | no |
| <a name="input_cato_account_id"></a> [cato\_account\_id](#input\_cato\_account\_id) | The Account ID for the Cato Management Application. | `string` | n/a | yes |
| <a name="input_cato_api_token"></a> [cato\_api\_token](#input\_cato\_api\_token) | The API token for the Cato Management Application. | `string` | n/a | yes |
| <a name="input_cato_asn"></a> [cato\_asn](#input\_cato\_asn) | The BGP ASN for Cato. | `number` | n/a | yes |
| <a name="input_cato_authMessage_cipher"></a> [cato\_authMessage\_cipher](#input\_cato\_authMessage\_cipher) | Cato Phase 2 ciphers.  The SA tunnel encryption method.<br/>  Note: For sites with bandwidth > 100Mbps, use only AES\_GCM\_128 or AES\_GCM\_256. For bandwidth < 100Mbps, use AES\_CBC algorithms.<br/>  Valid options are: <br/>    AES\_CBC\_128, AES\_CBC\_256, AES\_GCM\_128, AES\_GCM\_256, AUTOMATIC, DES3\_CBC, NONE | `string` | `"AES_GCM_256"` | no |
| <a name="input_cato_authMessage_dhGroup"></a> [cato\_authMessage\_dhGroup](#input\_cato\_authMessage\_dhGroup) | Cato Phase 2 DHGroup.  The Diffie-Hellman Group. The first number is the DH-group number, and the second number is <br/>   the corresponding prime modulus size in bits<br/>   Valid Options are: <br/>    AUTOMATIC, DH\_14\_MODP2048, DH\_15\_MODP3072, DH\_16\_MODP4096, DH\_19\_ECP256,<br/>    DH\_2\_MODP1024, DH\_20\_ECP384, DH\_21\_ECP521, DH\_5\_MODP1536, NONE | `string` | `"DH_14_MODP2048"` | no |
| <a name="input_cato_authMessage_integrity"></a> [cato\_authMessage\_integrity](#input\_cato\_authMessage\_integrity) | Cato Phase 2 Hashing Algorithm. The algorithm used to verify the integrity and authenticity of IPsec packets.<br/>  Note: Azure requires SHA256 or SHA384 for IKE Phase 2 integrity.<br/>  Valid Options are: <br/>    AUTOMATIC<br/>    MD5<br/>    NONE<br/>    SHA1<br/>    SHA256<br/>    SHA384<br/>    SHA512 | `string` | `"AUTOMATIC"` | no |
| <a name="input_cato_baseurl"></a> [cato\_baseurl](#input\_cato\_baseurl) | The base URL for the Cato API. | `string` | `"https://api.catonetworks.com/api/v1/graphql"` | no |
| <a name="input_cato_bfd_enabled"></a> [cato\_bfd\_enabled](#input\_cato\_bfd\_enabled) | Enable or disable BFD on the Cato BGP peer. This should only be enabled if BGP is also enabled. | `bool` | `true` | no |
| <a name="input_cato_bgp_md5_auth_key"></a> [cato\_bgp\_md5\_auth\_key](#input\_cato\_bgp\_md5\_auth\_key) | The MD5 authentication key for BGP peering. If null, MD5 auth is disabled. | `string` | `""` | no |
| <a name="input_cato_connectionMode"></a> [cato\_connectionMode](#input\_cato\_connectionMode) | Cato Connection Mode.  Determines the protocol for establishing the Security Association (SA) Tunnel. <br/>  Valid values are: Responder-Only Mode: Cato Cloud only responds to incoming requests by the initiator (e.g. a Firewall device) to establish a security association. <br/>  Bidirectional Mode: Both Cato Cloud and the peer device on customer site can initiate the IPSec SA establishment.<br/>  Valid Options are: <br/>    BIDIRECTIONAL<br/>    RESPONDER\_ONLY<br/>    Default to BIDIRECTIONAL | `string` | `"BIDIRECTIONAL"` | no |
| <a name="input_cato_identificationType"></a> [cato\_identificationType](#input\_cato\_identificationType) | Cato Identification Type.  The authentication identification type used for SA authentication. When using “BIDIRECTIONAL”, it is set to “IPv4” by default. <br/>  Other methods are available in Responder mode only. <br/>  Valid Options are: <br/>    EMAIL<br/>    FQDN<br/>    IPV4<br/>    KEY\_ID<br/>    Default to IPV4 | `string` | `"IPV4"` | no |
| <a name="input_cato_initMessage_cipher"></a> [cato\_initMessage\_cipher](#input\_cato\_initMessage\_cipher) | Cato Phase 1 ciphers.  The SA tunnel encryption method. <br/>  Note: For sites with bandwidth > 100Mbps, use only AES\_GCM\_128 or AES\_GCM\_256. For bandwidth < 100Mbps, use AES\_CBC algorithms.<br/>  Valid options are: <br/>    AES\_CBC\_128, AES\_CBC\_256, AES\_GCM\_128, AES\_GCM\_256, AUTOMATIC, DES3\_CBC, NONE | `string` | `"AES_GCM_256"` | no |
| <a name="input_cato_initMessage_dhGroup"></a> [cato\_initMessage\_dhGroup](#input\_cato\_initMessage\_dhGroup) | Cato Phase 1 DHGroup.  The Diffie-Hellman Group. The first number is the DH-group number, and the second number is <br/>   the corresponding prime modulus size in bits<br/>   Valid Options are: <br/>    AUTOMATIC, DH\_14\_MODP2048, DH\_15\_MODP3072, DH\_16\_MODP4096, DH\_19\_ECP256,<br/>    DH\_2\_MODP1024, DH\_20\_ECP384, DH\_21\_ECP521, DH\_5\_MODP1536, NONE | `string` | `"DH_14_MODP2048"` | no |
| <a name="input_cato_initMessage_integrity"></a> [cato\_initMessage\_integrity](#input\_cato\_initMessage\_integrity) | Cato Phase 1 Hashing Algorithm.  The algorithm used to verify the integrity and authenticity of IPsec packets<br/>   Valid Options are: <br/>    AUTOMATIC, MD5, NONE, SHA1, SHA256, SHA384, SHA512<br/>    Default to AUTOMATIC | `string` | `"AUTOMATIC"` | no |
| <a name="input_cato_initMessage_prf"></a> [cato\_initMessage\_prf](#input\_cato\_initMessage\_prf) | Cato Phase 1 Hashing Algorithm for The Pseudo-random function (PRF) used to derive the cryptographic keys used in the SA establishment process. <br/>  Valid Options are: <br/>    AUTOMATIC, MD5, NONE, SHA1, SHA256, SHA384, SHA512<br/>    Default to AUTOMATIC | `string` | `"SHA256"` | no |
| <a name="input_cato_local_networks"></a> [cato\_local\_networks](#input\_cato\_local\_networks) | If we aren't using BGP, we will need a list of CIDRs which live behind Cato<br/>  for more information [https://support.catonetworks.com/hc/en-us/articles/14110195123485-Working-with-the-Cato-System-Range](https://support.catonetworks.com/hc/en-us/articles/14110195123485-Working-with-the-Cato-System-Range)<br/>  Default: ["10.41.0.0/16", "10.254.254.0/24"] | `list(string)` | <pre>[<br/>  "10.41.0.0/16",<br/>  "10.254.254.0/24"<br/>]</pre> | no |
| <a name="input_cato_primary_bgp_advertise_all_routes"></a> [cato\_primary\_bgp\_advertise\_all\_routes](#input\_cato\_primary\_bgp\_advertise\_all\_routes) | Advertise all routes from Cato to the primary peer. | `bool` | `true` | no |
| <a name="input_cato_primary_bgp_advertise_default_route"></a> [cato\_primary\_bgp\_advertise\_default\_route](#input\_cato\_primary\_bgp\_advertise\_default\_route) | Advertise the default route from Cato to the primary peer. | `bool` | `false` | no |
| <a name="input_cato_primary_bgp_advertise_summary_route"></a> [cato\_primary\_bgp\_advertise\_summary\_route](#input\_cato\_primary\_bgp\_advertise\_summary\_route) | Advertise summary routes from Cato to the primary peer. | `bool` | `false` | no |
| <a name="input_cato_primary_bgp_bfd_multiplier"></a> [cato\_primary\_bgp\_bfd\_multiplier](#input\_cato\_primary\_bgp\_bfd\_multiplier) | The BFD multiplier for the primary peer, which determines the detection time. The recommended default for internet-based connections is 5. | `number` | `5` | no |
| <a name="input_cato_primary_bgp_bfd_receive_interval"></a> [cato\_primary\_bgp\_bfd\_receive\_interval](#input\_cato\_primary\_bgp\_bfd\_receive\_interval) | The BFD receive interval in milliseconds for the primary peer. The recommended default for internet-based connections is 1000ms. | `number` | `1000` | no |
| <a name="input_cato_primary_bgp_bfd_transmit_interval"></a> [cato\_primary\_bgp\_bfd\_transmit\_interval](#input\_cato\_primary\_bgp\_bfd\_transmit\_interval) | The BFD transmit interval in milliseconds for the primary peer. The recommended default for internet-based connections is 1000ms. | `number` | `1000` | no |
| <a name="input_cato_primary_bgp_default_action"></a> [cato\_primary\_bgp\_default\_action](#input\_cato\_primary\_bgp\_default\_action) | The default action for the primary BGP peer, can be ACCEPT or REJECT. | `string` | `"ACCEPT"` | no |
| <a name="input_cato_primary_bgp_ip"></a> [cato\_primary\_bgp\_ip](#input\_cato\_primary\_bgp\_ip) | The BGP peering IP address for the primary Cato link. Must be in the same /30 or /31 subnet as the corresponding azure\_primary\_bgp\_ip. | `string` | n/a | yes |
| <a name="input_cato_primary_bgp_metric"></a> [cato\_primary\_bgp\_metric](#input\_cato\_primary\_bgp\_metric) | The BGP metric for the primary peer. | `number` | `100` | no |
| <a name="input_cato_primary_bgp_peer_name"></a> [cato\_primary\_bgp\_peer\_name](#input\_cato\_primary\_bgp\_peer\_name) | Name for the primary BGP peer in Cato. | `string` | `"Azure-Primary-BGP-Peer"` | no |
| <a name="input_cato_secondary_bgp_advertise_all_routes"></a> [cato\_secondary\_bgp\_advertise\_all\_routes](#input\_cato\_secondary\_bgp\_advertise\_all\_routes) | Advertise all routes from Cato to the secondary peer. | `bool` | `true` | no |
| <a name="input_cato_secondary_bgp_advertise_default_route"></a> [cato\_secondary\_bgp\_advertise\_default\_route](#input\_cato\_secondary\_bgp\_advertise\_default\_route) | Advertise the default route from Cato to the secondary peer. | `bool` | `false` | no |
| <a name="input_cato_secondary_bgp_advertise_summary_route"></a> [cato\_secondary\_bgp\_advertise\_summary\_route](#input\_cato\_secondary\_bgp\_advertise\_summary\_route) | Advertise summary routes from Cato to the secondary peer. | `bool` | `false` | no |
| <a name="input_cato_secondary_bgp_bfd_multiplier"></a> [cato\_secondary\_bgp\_bfd\_multiplier](#input\_cato\_secondary\_bgp\_bfd\_multiplier) | The BFD multiplier for the secondary peer, which determines the detection time. The recommended default for internet-based connections is 5. | `number` | `5` | no |
| <a name="input_cato_secondary_bgp_bfd_receive_interval"></a> [cato\_secondary\_bgp\_bfd\_receive\_interval](#input\_cato\_secondary\_bgp\_bfd\_receive\_interval) | The BFD receive interval in milliseconds for the secondary peer. The recommended default for internet-based connections is 1000ms. | `number` | `1000` | no |
| <a name="input_cato_secondary_bgp_bfd_transmit_interval"></a> [cato\_secondary\_bgp\_bfd\_transmit\_interval](#input\_cato\_secondary\_bgp\_bfd\_transmit\_interval) | The BFD transmit interval in milliseconds for the secondary peer. The recommended default for internet-based connections is 1000ms. | `number` | `1000` | no |
| <a name="input_cato_secondary_bgp_default_action"></a> [cato\_secondary\_bgp\_default\_action](#input\_cato\_secondary\_bgp\_default\_action) | The default action for the secondary BGP peer, can be ACCEPT or REJECT. | `string` | `"ACCEPT"` | no |
| <a name="input_cato_secondary_bgp_ip"></a> [cato\_secondary\_bgp\_ip](#input\_cato\_secondary\_bgp\_ip) | The BGP peering IP address for the secondary Cato link. Required if secondary\_cato\_pop\_ip is not null. | `string` | `null` | no |
| <a name="input_cato_secondary_bgp_metric"></a> [cato\_secondary\_bgp\_metric](#input\_cato\_secondary\_bgp\_metric) | The BGP metric for the secondary peer. | `number` | `200` | no |
| <a name="input_cato_secondary_bgp_peer_name"></a> [cato\_secondary\_bgp\_peer\_name](#input\_cato\_secondary\_bgp\_peer\_name) | Name for the secondary BGP peer in Cato. | `string` | `"Azure-Secondary-BGP-Peer"` | no |
| <a name="input_cato_site_address_cidrs"></a> [cato\_site\_address\_cidrs](#input\_cato\_site\_address\_cidrs) | A list of address CIDRs for the Azure VPN Site resource. | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_custom_vpn_gateway_connection_name"></a> [custom\_vpn\_gateway\_connection\_name](#input\_custom\_vpn\_gateway\_connection\_name) | Optional custom name for the Azure VPN Gateway Connection. If not provided, a name will be generated based on the site\_name. | `string` | `null` | no |
| <a name="input_custom_vpn_gateway_name"></a> [custom\_vpn\_gateway\_name](#input\_custom\_vpn\_gateway\_name) | Optional custom name for the Azure VPN Gateway. If not provided, a name will be generated based on the site\_name. | `string` | `null` | no |
| <a name="input_custom_vpn_site_name"></a> [custom\_vpn\_site\_name](#input\_custom\_vpn\_site\_name) | Optional custom name for the Azure VPN Site. If not provided, a name will be generated based on the site\_name. | `string` | `null` | no |
| <a name="input_downstream_bw"></a> [downstream\_bw](#input\_downstream\_bw) | The downstream bandwidth in Mbps. | `number` | `1000` | no |
| <a name="input_enable_ipsec_site_update"></a> [enable\_ipsec\_site\_update](#input\_enable\_ipsec\_site\_update) | If true, the terraform\_data resource will run to update the IPsec site details via API. | `bool` | `true` | no |
| <a name="input_ipsec_sa_data_size_kb"></a> [ipsec\_sa\_data\_size\_kb](#input\_ipsec\_sa\_data\_size\_kb) | The IPSec Security Association payload size in KB for the site-to-site VPN tunnel. | `number` | `102400000` | no |
| <a name="input_ipsec_sa_lifetime_sec"></a> [ipsec\_sa\_lifetime\_sec](#input\_ipsec\_sa\_lifetime\_sec) | The IPSec Security Association lifetime in seconds for the site-to-site VPN tunnel. | `number` | `19800` | no |
| <a name="input_native_network_range"></a> [native\_network\_range](#input\_native\_network\_range) | The native network range for the site. If null, it will be automatically populated from the Azure Hub's address prefix. | `string` | `null` | no |
| <a name="input_peer_networks"></a> [peer\_networks](#input\_peer\_networks) | (Optional) List of Networks on the Azure side (if BGP is disabled)<br/>  Examples: <br/>  ["servers:10.0.0.0/24","devices:10.1.0.0/24"] | `list(string)` | `null` | no |
| <a name="input_primary_cato_pop_ip"></a> [primary\_cato\_pop\_ip](#input\_primary\_cato\_pop\_ip) | The public IP address of the primary Cato PoP. Must match the name of an allocated IP in Cato. | `string` | n/a | yes |
| <a name="input_primary_connection_shared_key"></a> [primary\_connection\_shared\_key](#input\_primary\_connection\_shared\_key) | The pre-shared key for the primary connection. If null, a random one will be generated. | `string` | `null` | no |
| <a name="input_secondary_cato_pop_ip"></a> [secondary\_cato\_pop\_ip](#input\_secondary\_cato\_pop\_ip) | The public IP address of the secondary Cato PoP. Must match the name of an allocated IP in Cato. If null, a secondary connection will not be configured. | `string` | `null` | no |
| <a name="input_secondary_connection_shared_key"></a> [secondary\_connection\_shared\_key](#input\_secondary\_connection\_shared\_key) | The pre-shared key for the secondary connection. If null, a random one will be generated. | `string` | `null` | no |
| <a name="input_site_description"></a> [site\_description](#input\_site\_description) | A description for the site in the Cato Management Application. | `string` | `"Azure VWAN Hub Connection"` | no |
| <a name="input_site_location"></a> [site\_location](#input\_site\_location) | An object representing the site's physical location. | <pre>object({<br/>    city         = string<br/>    country_code = string<br/>    state_code   = string<br/>    timezone     = string<br/>  })</pre> | <pre>{<br/>  "city": "Ashburn",<br/>  "country_code": "US",<br/>  "state_code": "VA",<br/>  "timezone": "America/New_York"<br/>}</pre> | no |
| <a name="input_site_name"></a> [site\_name](#input\_site\_name) | The name of the site in the Cato Management Application. | `string` | n/a | yes |
| <a name="input_site_type"></a> [site\_type](#input\_site\_type) | The type of the site in Cato (e.g., CLOUD\_DC). | `string` | `"CLOUD_DC"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to all taggable Azure resources. | `map(string)` | `{}` | no |
| <a name="input_upstream_bw"></a> [upstream\_bw](#input\_upstream\_bw) | The upstream bandwidth in Mbps. | `number` | `1000` | no |
| <a name="input_vpn_site_primary_link_name"></a> [vpn\_site\_primary\_link\_name](#input\_vpn\_site\_primary\_link\_name) | The name for the primary link on the Azure VPN Site. | `string` | `"PrimaryLink"` | no |
| <a name="input_vpn_site_secondary_link_name"></a> [vpn\_site\_secondary\_link\_name](#input\_vpn\_site\_secondary\_link\_name) | The name for the secondary link on the Azure VPN Site. | `string` | `"SecondaryLink"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azure_primary_public_ip"></a> [azure\_primary\_public\_ip](#output\_azure\_primary\_public\_ip) | The public IP address of the primary instance of the Azure VPN Gateway. |
| <a name="output_azure_secondary_public_ip"></a> [azure\_secondary\_public\_ip](#output\_azure\_secondary\_public\_ip) | The public IP address of the secondary instance of the Azure VPN Gateway. This will be an empty string if a secondary connection is not configured. |
| <a name="output_azure_vpn_gateway_connection_id"></a> [azure\_vpn\_gateway\_connection\_id](#output\_azure\_vpn\_gateway\_connection\_id) | The resource ID of the Azure VPN Gateway Connection. |
| <a name="output_azure_vpn_gateway_id"></a> [azure\_vpn\_gateway\_id](#output\_azure\_vpn\_gateway\_id) | The resource ID of the Azure VPN Gateway. |
| <a name="output_azure_vpn_site_id"></a> [azure\_vpn\_site\_id](#output\_azure\_vpn\_site\_id) | The resource ID of the Azure VPN Site. |
| <a name="output_cato_ipsec_site_id"></a> [cato\_ipsec\_site\_id](#output\_cato\_ipsec\_site\_id) | The ID of the Cato IPsec site that was created. |
| <a name="output_primary_preshared_key"></a> [primary\_preshared\_key](#output\_primary\_preshared\_key) | The pre-shared key used for the primary VPN connection. This will be the generated key if one was not provided. |
| <a name="output_secondary_preshared_key"></a> [secondary\_preshared\_key](#output\_secondary\_preshared\_key) | The pre-shared key used for the secondary VPN connection. This will be the generated key if one was not provided. |
<!-- END_TF_DOCS -->