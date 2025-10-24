# lsplocal

This is a very simple plugin that allows optionally overriding LSP configurations with
by project configuration files.

## Installation

Using `vim.pack`

```lua
vim.pack.add({
  'https://github.com/j-lohuis/lsplocal',
})
```

## Usage

For example using it in `<rtp>/lsp/rust_analyzer.lua`:

```lua
-- The default global rust-analyzer configuration
local default = {
  cmd = { 'rust-analyzer' },
  settings = {
    ['rust-analyzer'] = {
      checkOnSave = true,
      check = {
        allTargets = true,
        command = "clippy",
      },
      cargo = {
        features = "all",
      },
    }
  },
}

-- Using the plugin, try to load `$(pwd)/.nvim/rust_analyzer.json` (or parent directories)
-- If it exists, use it to override settings from `default`
return require('lsplocal').maybe_load_local('rust_analyzer', default)
```

Example of `$(pwd)/.nvim/rust_analyzer.json`:

```json
{
    "settings": {
        "rust-analyzer": {
            "cargo": {
                "features": []
            }
        }
    }
}
```
