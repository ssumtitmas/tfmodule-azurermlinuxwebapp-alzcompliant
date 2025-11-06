# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Private endpoint support for internal-only deployments
- `public_network_access_enabled` variable to control public access
- `private_endpoint` variable for configuring Azure Private Link
- New `internal` example demonstrating private endpoint deployment
- Private endpoint outputs including private IP address
- Comprehensive README for internal deployment example

### Changed
- Module now supports disabling public network access
- Enhanced network security configuration options

## [1.0.0] - 2025-11-06

### Added
- Initial release of ALZ-compliant Azure Linux Web App Terraform module
- Support for Azure Landing Zone (ALZ) compliance
- Secure defaults (HTTPS-only, TLS 1.2+, managed identity)
- Comprehensive diagnostic settings with Log Analytics integration
- Network access restrictions and IP filtering
- Deployment slot support for zero-downtime deployments
- System-assigned and user-assigned managed identity support
- Three usage examples: basic, diagnostics, and private-ase
- ALZ-compliant naming conventions
- Full documentation and usage guides

### Security
- HTTPS-only traffic enforcement by default
- Minimum TLS 1.2 requirement
- Managed identity enabled by default
- Diagnostic logging to Log Analytics workspace
- Network access restriction capabilities

[1.0.0]: https://github.com/ssumtitmas/tfmodule-azurermlinuxwebapp-alzcompliant/releases/tag/v1.0.0
