vim.filetype.add({
  pattern = {
    [".*/templates/.*%.tpl"] = "helm",
    [".*/templates/.*%.ya?ml"] = "helm",
    [".*/templates/.*%.txt"] = "helm",
    ["helmfile.*%.ya?ml"] = "helm",
    ["helmfile.*%.ya?ml.gotmpl"] = "helm",
    ["values.*%.yaml"] = "yaml.helm-values",
  },
  filename = {
    -- TODO: enable if helm-ls supports Chart.yaml
    -- ["Chart.yaml"] = "yaml.helm-chartfile",
  },
})
