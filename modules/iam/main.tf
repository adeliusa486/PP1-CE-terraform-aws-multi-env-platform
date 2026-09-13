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