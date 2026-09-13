# Define the Policy Logic
data "aws_iam_policy_document" "developer_boundary" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:Describe*",
      "ecs:Describe*",
      "rds:Describe*",
      "cloudwatch:Get*"
    ]
    resources = ["*"]
  }

  # Dynamic block: Only added if the environment is NOT prod
  dynamic "statement" {
    for_each = var.environment != "prod" ? [1] : []
    content {
      effect = "Allow"
      actions = [
        "ec2:*",
        "ecs:*",
        "rds:*"
      ]
      resources = ["*"]
    }
  }
}

# Create the Policy in AWS
resource "aws_iam_policy" "developer_policy" {
  name        = "${var.environment}-developer-policy"
  description = "Developer access boundary for the ${var.environment} environment"
  policy      = data.aws_iam_policy_document.developer_boundary.json
}

# Create the IAM Group and attach the policy
resource "aws_iam_group" "developers" {
  name = "${var.environment}-developers"
}

resource "aws_iam_group_policy_attachment" "developer_attach" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.developer_policy.arn
}
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["1c58a3a8518e8759bf075b76b750d4f2df264fcd", "6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource "aws_iam_role" "github_actions" {
  name = "${var.environment}-github-actions-deploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub": "repo:adeliusa486/PP1-CE-terraform-aws-multi-env-platform:*"
          }
          StringEquals = {
            "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_admin" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
