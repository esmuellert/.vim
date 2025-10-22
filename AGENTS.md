# Agent Instructions

This is a Neovim configuration repository. Refer to README.md for detailed structure.

## Add a new plugin

1. Look up the plugin's GitHub repository and search for installation guide and best practice setup
2. Add plugin configuration to the appropriate file in `lua/plugins/` following the existing structure
3. Register the plugin in `lua/config/plugins-enabled.lua` to enable it

## Documentation

Only create simple, minimal, and necessary docs, put it in `dev-docs/` folder, and add timestamp to filename with format `yyyy-mm-dd_hh-mm`
