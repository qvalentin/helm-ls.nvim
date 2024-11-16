# Nvim plugin for helm-ls

A lua plugin for [Helm](https://helm.sh/) adding additional features using [helm-ls](https://github.com/mrjosh/helm-ls/).
The plugin can be used as an alternative to [towolf/vim-helm](https://github.com/towolf/vim-helm) for neovim.

The plugin is in early development.

## Features

- Filetypes for Helm

- experimental: Overwrite templates with their current values using virtual text [demo](https://github.com/mrjosh/helm-ls/issues/26#issuecomment-2308893242)

- experimental: Show hints highlighting the effect of `nindent` and `indent` functions
  ![demo for indent hints](https://raw.githubusercontent.com/qvalentin/helm-ls.nvim/main/doc/gifs/indent-hints.gif)

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

The plugin requires [helm-ls](https://github.com/mrjosh/helm-ls) and the helm tree-sitter grammar.

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
