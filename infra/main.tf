# 1. Private OCI registry for the chart. Name must equal the Helm OCI path.
resource "aws_ecr_repository" "chart" {
  name                 = "charts/${var.chart_name}"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

resource "aws_ecr_lifecycle_policy" "chart" {
  repository = aws_ecr_repository.chart.name
  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep the last ${var.keep_last_versions} chart versions"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = var.keep_last_versions
      }
      action = { type = "expire" }
    }]
  })
}

# 2. GitHub Actions -> AWS keyless trust (one per AWS account)
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

data "aws_iam_policy_document" "trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Only release tags from this repo can publish
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repo}:ref:refs/tags/${var.chart_name}-v*"]
    }
  }
}

resource "aws_iam_role" "chart_publisher" {
  name               = "gha-chart-publisher-${var.chart_name}"
  assume_role_policy = data.aws_iam_policy_document.trust.json
}

# 3. Least privilege: push to this one repository only
data "aws_iam_policy_document" "publish" {
  statement {
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"] # this action does not support resource-level scoping
  }

  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
    ]
    resources = [aws_ecr_repository.chart.arn]
  }
}

resource "aws_iam_role_policy" "publish" {
  role   = aws_iam_role.chart_publisher.id
  policy = data.aws_iam_policy_document.publish.json
}