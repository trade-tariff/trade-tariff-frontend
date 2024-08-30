data "aws_iam_policy_document" "secrets" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]
    resources = [
      data.aws_secretsmanager_secret.redis_connection_string.arn,
      data.aws_secretsmanager_secret.frontend_secret_key_base.arn,
      data.aws_secretsmanager_secret.sentry_dsn.arn,
      data.aws_secretsmanager_secret.green_lanes_api_tokens.arn,
      data.aws_secretsmanager_secret.google_tag_manager_container_id.arn,
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncryptFrom",
      "kms:ReEncryptTo",
      "kms:GenerateDataKeyPair",
      "kms:GenerateDataKeyPairWithoutPlainText",
      "kms:GenerateDataKeyWithoutPlaintext"
    ]
    resources = [
      data.aws_kms_key.secretsmanager_key.arn
    ]
  }
}

data "aws_iam_policy_document" "emails" {
  statement {
    effect = "Allow"
    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "secrets" {
  name   = "frontend-execution-role-secrets-policy"
  policy = data.aws_iam_policy_document.secrets.json
}

resource "aws_iam_policy" "emails" {
  name   = "frontend-task-role-emails-policy"
  policy = data.aws_iam_policy_document.emails.json
}

data "aws_iam_policy_document" "exec" {
  statement {
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "exec" {
  name   = "frontend-task-role-exec-policy"
  policy = data.aws_iam_policy_document.exec.json
}
