locals {
  # The output of the azapi_resource is a map, so we can access its properties directly.
  vpn_gateway_properties = data.azapi_resource.vpn_gateway_details.output.properties

  # Extract the public IPs for each instance from the bgpPeeringAddresses block within the bgpSettings.
  # The Data Source doesn't collect the IP Addresses like it should so we have to use the bgpSettings to get them.
  azure_primary_public_ip   = try(local.vpn_gateway_properties.bgpSettings.bgpPeeringAddresses[0].tunnelIpAddresses[0], null)
  azure_secondary_public_ip = try(local.vpn_gateway_properties.bgpSettings.bgpPeeringAddresses[1].tunnelIpAddresses[0], null)
}
