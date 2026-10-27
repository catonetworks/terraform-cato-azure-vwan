# All providers are mocked; these plans cannot change Azure or CMA.
# Target only the gateway and its lookup dependencies to isolate hub ID handling.
mock_provider "azurerm" {
  mock_data "azurerm_resource_group" {
    defaults = {
      name = "lab-vWAN-rg"
    }
  }

  mock_data "azurerm_virtual_hub" {
    defaults = {
      id             = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/lab-vWAN-rg/providers/Microsoft.Network/virtualHubs/lab-vWAN-hub"
      location       = "westeurope"
      address_prefix = "10.150.0.0/23"
    }
  }
}

mock_provider "azapi" {}
mock_provider "cato" {}
mock_provider "random" {}

variables {
  cato_api_token            = "unused-by-mocked-provider"
  cato_account_id           = "1"
  azure_resource_group_name = "lab-vWAN-rg"
  azure_vwan_name           = "lab-vWAN"
  azure_hub_name            = "lab-vWAN-hub"
  site_name                 = "mock-vwan-site"
  primary_cato_pop_ip       = "203.0.113.10"
  secondary_cato_pop_ip     = "203.0.113.11"
  bgp_enabled               = false
  enable_ipsec_site_update  = false
  site_location = {
    city         = "Amsterdam"
    country_code = "NL"
    state_code   = null
    timezone     = "Europe/Amsterdam"
  }
}

run "default_hub_lookup" {
  command = plan

  plan_options {
    target = [azurerm_vpn_gateway.cato_vpn_gateway]
  }

  assert {
    condition     = azurerm_vpn_gateway.cato_vpn_gateway.virtual_hub_id == data.azurerm_virtual_hub.hub.id
    error_message = "Without an override, the gateway must retain the name-based hub lookup."
  }
}

run "preserve_gateway_response_casing" {
  command = plan

  plan_options {
    target = [azurerm_vpn_gateway.cato_vpn_gateway]
  }

  variables {
    azure_hub_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/lab-VWAN-rg/providers/Microsoft.Network/virtualHubs/lab-vWAN-hub"
  }

  assert {
    condition     = azurerm_vpn_gateway.cato_vpn_gateway.virtual_hub_id == var.azure_hub_id
    error_message = "The gateway must preserve the exact override casing returned by Azure."
  }
}

run "reject_different_hub" {
  command = plan

  plan_options {
    target = [azurerm_vpn_gateway.cato_vpn_gateway]
  }

  variables {
    azure_hub_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/lab-VWAN-rg/providers/Microsoft.Network/virtualHubs/other-hub"
  }

  expect_failures = [azurerm_vpn_gateway.cato_vpn_gateway]
}

run "reject_different_resource_group" {
  command = plan

  plan_options {
    target = [azurerm_vpn_gateway.cato_vpn_gateway]
  }

  variables {
    azure_hub_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/other-rg/providers/Microsoft.Network/virtualHubs/lab-vWAN-hub"
  }

  expect_failures = [azurerm_vpn_gateway.cato_vpn_gateway]
}

run "reject_different_subscription" {
  command = plan

  plan_options {
    target = [azurerm_vpn_gateway.cato_vpn_gateway]
  }

  variables {
    azure_hub_id = "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/lab-VWAN-rg/providers/Microsoft.Network/virtualHubs/lab-vWAN-hub"
  }

  expect_failures = [azurerm_vpn_gateway.cato_vpn_gateway]
}

run "reject_empty_override" {
  command = plan

  plan_options {
    target = [azurerm_vpn_gateway.cato_vpn_gateway]
  }

  variables {
    azure_hub_id = ""
  }

  expect_failures = [azurerm_vpn_gateway.cato_vpn_gateway]
}
