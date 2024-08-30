# Nvim plugin for helm-ls

[helm-ls](https://github.com/mrjosh/helm-ls/)

**Major work in progress**

## Planned features

- **WIP**: Overwrite templates with their current values using virtual text [demo](https://github.com/mrjosh/helm-ls/issues/26#issuecomment-2308893242)

- **WIP**: Show hints highlighting the effect of `nindent` and `indent` functions
  ![demo for indent hints](https://raw.githubusercontent.com/qvalentin/helm-ls.nvim/main/doc/gifs/indent-hints.gif)


## Installing

### Using lazy

```lua
{
    "qvalentin/helm-ls.nvim",
    ft = "helm",
    opts = {},
}
```

If you are not using lazy make sure to call `require("helm-ls").setup()` in your lua config.

