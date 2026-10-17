locals {
  chart = var.chart_repository == null ? "${path.module}/../../charts/ml-api" : "ml-api"
}

# The same values files an MLE maintains drive the deployment.
resource "helm_release" "service" {
  name             = var.service
  namespace        = var.environment
  create_namespace = true

  repository = var.chart_repository
  chart      = local.chart
  version    = var.chart_version

  atomic          = true # roll back automatically if the rollout fails
  cleanup_on_fail = true
  timeout         = 300

  values = [
    file("${path.module}/../../services/${var.service}/values.yaml"),
    file("${path.module}/../../services/${var.service}/values-${var.environment}.yaml"),
  ]

  # Secrets are referenced by name only; values never pass through Terraform or Git.
  set = [for s in(var.existing_secret == "" ? [] : [var.existing_secret]) : { name = "secrets.existingSecret", value = s }]
}
