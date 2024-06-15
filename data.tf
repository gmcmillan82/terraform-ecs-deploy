data "aws_caller_identity" "current" {}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "private" {
  filter {
    name   = "tag:Public"
    values = ["false"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "tag:Public"
    values = ["true"]
  }
}

data "aws_iam_policy" "ecs_task_execution" {
  name = "AmazonECSTaskExecutionRolePolicy"
}


data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}

# Used by OIDC, which I couldn't implement due to lack of IAM permissions
# data "aws_iam_policy_document" "gha_ecr_assume_role" {
#   statement {
#     effect = "Allow"
#
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#
#     principals {
#       type        = "Federated"
#       identifiers = [aws_iam_openid_connect_provider.github.arn]
#     }
#
#     condition {
#       test     = "StringLike"
#       variable = "token.actions.githubusercontent.com:sub"
#       values   = [var.demo_app_repo]
#     }
#
#     condition {
#       test     = "StringEquals"
#       variable = "token.actions.githubusercontent.com:aud"
#       values   = ["sts.amazonaws.com"]
#     }
#   }
# }
#
# data "aws_iam_policy_document" "ecr_policy" {
#   statement {
#     actions = [
#       "ecr:GetDownloadUrlForLayer",
#       "ecr:BatchGetImage",
#       "ecr:BatchCheckLayerAvailability",
#       "ecr:PutImage",
#       "ecr:InitiateLayerUpload",
#       "ecr:UploadLayerPart",
#       "ecr:CompleteLayerUpload",
#       "ecr:DescribeRepositories",
#       "ecr:GetAuthorizationToken",
#       "ecr:ListImages",
#       "ecr:CreateRepository",
#       "ecr:DeleteRepository",
#       "ecr:DeleteRepositoryPolicy",
#       "ecr:DescribeImages",
#       "ecr:DescribeRepositories",
#       "ecr:GetRepositoryPolicy",
#       "ecr:ListTagsForResource",
#       "ecr:PutImageTagMutability",
#       "ecr:PutLifecyclePolicy",
#       "ecr:SetRepositoryPolicy",
#       "ecr:DeleteLifecyclePolicy",
#       "ecr:GetLifecyclePolicy",
#       "ecr:GetLifecyclePolicyPreview"
#     ]
#     resources = ["*"]
#   }
# }
#
