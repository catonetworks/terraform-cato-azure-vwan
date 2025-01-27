# CATO IPSec Azure vWAN Terraform Module
This Terraform module provisions an IPSec connection between CATO Cloud and Azure vWAN. It creates primary and secondary tunnels for high availability (HA) and establishes a BGP connection to enable dynamic routing.

## Requirements
This terraform module requires:
- Two [Allocated IPs in CATO](https://support.catonetworks.com/hc/en-us/articles/4413273467153-Allocating-IP-Addresses-for-the-Account) Cloud
- [API Key in CATO](https://support.catonetworks.com/hc/en-us/articles/4413280536081-Generating-API-Keys-for-the-Cato-API)
- A configured vWAN and Hub
  - Note: A VPN gateway is not required, as it will be created by the module. 

## Providers

| Name                                                   | Version   |
|--------------------------------------------------------|-----------|
| <a name="provider_cato"></a> [cato](https://registry.terraform.io/providers/catonetworks/cato/latest)    | >= 0.0.12 |
| <a name="provider_azure"></a> [azurerm](https://registry.terraform.io/providers/hashicorp/azurerm/latest) | >= 4.1.0  | 

## Resources

| Name                                           | Type     |
|------------------------------------------------|----------|
| cato_allocatedIp                               | data     |
| [cato_ipsec_site](https://registry.terraform.io/providers/catonetworks/cato/latest/docs/resources/ipsec_site)                            | resource |
| [azurerm_public_ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip)                          | resource |
| [azurerm_virtual_network_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway)            | resource |
| [azurerm_local_network_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/local_network_gateway)              | resource |
| [azurerm_virtual_network_gateway_connection](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway_connection) | resource |

## Usage

```hcl
# Azure/Cato VWAN Module
module "azure-vwan" {
  source                       = "catonetworks/azure-vwan/cato"
  token                        = "xxxxxxx"
  account_id                   = "xxxxxxx"
  azure_subscription_id        = "abcde12345-abcd-1234-abcd-abcde12345"
  azure_vwan_hub_id            = "/subscriptions/abcde12345-abcd-1234-abcd-abcde12345/resourceGroups/YOUR_RESOURCE_GROUP_NAME/providers/Microsoft.Network/virtualHubs/YOUR_VIRTUAL_HUB_NAME"
  site_name                    = "Azure vWAN"
  cato_site_address_cidrs      = ["10.4.0.0/16"]
  vpn_site_primary_link_name   = "VPN_vWAN2Cato_Primary"
  vpn_site_secondary_link_name = "VPN_vWAN2Cato_Secondary"
  site_location = {
    city         = "Antelope"
    country_code = "US"
    state_code   = "US-CA"
    timezone     = "US/Mountain"
  }
  cato_primary_public_ip         = "150.195.206.90"
  cato_secondary_public_ip       = "149.20.204.46"
  bgp_enabled                    = true
  cato_asn                       = 65001
  cato_primary_peering_address   = "192.168.100.1"
  cato_secondary_peering_address = "192.168.100.2"
}
```

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
