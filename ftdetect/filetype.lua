vim.filetype.add({
  pattern = {
    [".*/templates/.*%.tpl"] = "helm",
    [".*/templates/.*%.yaml"] = "helm",
    ["helmfile.*%.yaml"] = "helm",
    ["values.*%.yaml"] = "yaml.helm-values",
  },
  filename = {
    ["Chart.yaml"] = "yaml.helm-chartfile",
  },
})
