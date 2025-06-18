# Changelog

## 0.0.1 (2025-01-27)

### Features
- Initial commit 

## 0.0.3 (2025-01-27)
- Updated readme to specify clear text example param values

## 0.1.0 (2025-06-18)
- Added
  - Declarative Approach: The module is now fully declarative, removing all local-exec provisioners for Azure resources.
  - Prerequisite Data Sources: The module now requires a pre-existing Azure Resource Group, Virtual WAN, and Virtual Hub, which it looks up using data sources for a more stable and predictable workflow.
  - Flexible Naming: Added optional custom_*_name variables to allow users to specify exact names for Azure resources. If left null, the module generates sensible, predictable names based on the site_name.
  - Granular BGP Control: Introduced a comprehensive set of variables to control BGP behavior for each peer independently, including:
    - Custom peer names (cato_primary_bgp_peer_name).
    - BGP metric (cato_primary_bgp_metric).
    - Fine-grained route advertisement controls (advertise_all_routes, advertise_default_route, advertise_summary_routes).
    - MD5 Authentication key (cato_bgp_md5_auth_key).
  - Configurable BFD Settings: BFD timers are now fully configurable for each peer using a bfd_settings block and dedicated variables (cato_primary_bgp_bfd_transmit_interval, etc.).
  - Tagging Support: Added a tags variable to apply a consistent set of user-defined tags to all taggable Azure resources.
  - Variable Validation: Implemented validation blocks for all variables with a fixed set of allowed values (e.g., IKE/IPsec settings, connection modes) to provide immediate feedback on invalid configurations.
  - Module Outputs: Created a comprehensive outputs.tf file to expose the IDs, IPs, and other important attributes of the created resources.
  - azapi Provider Integration: The module now uses the azapi provider to reliably fetch Azure VPN Gateway properties that are not exposed by the azurerm provider.
- Changed
  - Refactored cato_ipsec_site: Updated the resource to use the modern ipsec block structure with nested tunnels.
  - Refactored BGP Peer Configuration: The cato_bgp_peer resources have been updated to use the latest, more detailed attribute schema.
  - Default Cipher Update: Changed the default IKE/IPsec cipher to AES_GCM_256 to align with best practices for connections over 100Mbps.


