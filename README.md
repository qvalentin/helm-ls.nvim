# Nvim plugin for helm-ls

A neovim lua plugin for [Helm](https://helm.sh/) adding additional features using [helm-ls](https://github.com/mrjosh/helm-ls/).
The plugin can be used as an alternative to [towolf/vim-helm](https://github.com/towolf/vim-helm) for neovim.

The plugin is in early development.

## Features

- Filetypes for Helm

- experimental: Overwrite templates with their current values using virtual text (See [Demos](#demos))

- experimental: Show hints highlighting the effect of `nindent` and `indent` functions (See [Demos](#demos))

## Installing

### Using lazy

```lua
{
    "qvalentin/helm-ls.nvim",
    ft = "helm",
    opts = {
        -- leave emtpy or see below
    },
}
```

If you are not using lazy make sure to call `require("helm-ls").setup()` in your lua config.

### Requirments

The plugin requires [helm-ls](https://github.com/mrjosh/helm-ls) and the helm tree-sitter grammar for the additional features.
Install the helm tree-sitter grammar using `TSInstall` after installing the [nvim-treesitter plugin](https://github.com/nvim-treesitter/nvim-treesitter).

```
:TSInstall helm
```

## Configuration

Default config:

```lua
{
  conceal_templates = {
    -- enable the replacement of templates with virtual text of their current values
    enabled = true, -- this might change to false in the future
  },
  indent_hints = {
    -- enable hints for indent and nindent functions
    enabled = true,
    -- show the hints only for the line the cursor is on
    only_for_current_line = true,
  },
}
```

## Demos

<video src="https://github.com/user-attachments/assets/efae6e15-58a7-48d4-99c2-fd74fbb3a1b0" width="100%" controls></video>

![demo for indent hints](https://raw.githubusercontent.com/qvalentin/helm-ls.nvim/main/doc/gifs/indent-hints.gif)
