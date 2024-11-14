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
    ["Chart.yaml"] = "yaml.helm-chartfile",
  },
})
