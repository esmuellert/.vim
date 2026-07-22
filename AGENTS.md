# Agent Instructions

This is a Neovim configuration repository. Refer to README.md for detailed structure.

## Add a new plugin

1. Look up the plugin's GitHub repository and search for installation guide and best practice setup
2. Create a new file `lua/plugins/<name>.lua` returning a lazy.nvim spec (or add it to a
   related existing file). Every file under `lua/plugins/` is auto-imported by lazy.nvim —
   **presence enables the plugin; delete the file to remove it.** There is no central toggle list.

## Documentation

Only create simple, minimal, and necessary docs, put it in `dev-docs/` folder, and add timestamp to filename with format `yyyy-mm-dd_hh-mm`
For one set of same issue or top investigation, only write in one doc and modify it with new findings
