# Old code before I realised it wasn't possible to use OIDC

# resource "aws_iam_role" "ci_access" {
#   name               = "gha-ci-role"
#   assume_role_policy = data.aws_iam_policy_document.gha_ecr_assume_role.json
# }
#
# resource "aws_iam_role_policy" "github_actions_policy" {
#   name   = "github-actions-policy"
#   role   = aws_iam_role.ci_access.id
#   policy = data.aws_iam_policy_document.ecr_policy.json
# }
#
# resource "aws_iam_openid_connect_provider" "github" {
#   url             = "https://token.actions.githubusercontent.com"
#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
# }
#

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = data.aws_iam_policy.ecs_task_execution.arn
}
