locals {
  # https://ap-northeast-1.console.aws.amazon.com/lambda/home?region=ap-northeast-1#/create/app?applicationId=arn:aws:serverlessrepo:us-west-2:533243300146:applications/NewRelic-log-ingestion-s3
  name = "NewRelic-s3-log-ingestion"
}

data "aws_iam_policy_document" "role" {
  statement {
    sid     = "AssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "role" {
  name               = local.name
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.role.json
}


data "aws_iam_policy" "default" {
  name = "AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "policy" {
  statement {
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      var.kms_arn,
      var.bucket_arn,
      "${var.bucket_arn}/*",
    ]
  }
}

resource "aws_iam_policy" "policy" {
  name        = local.name
  description = "Policy for ${local.name}"
  policy      = data.aws_iam_policy_document.policy.json
}

resource "aws_iam_role_policy_attachment" "default" {
  for_each = {
    for p in [
      aws_iam_policy.policy,
      data.aws_iam_policy.default,
    ] : p.name => p.arn
  }

  role       = aws_iam_role.role.name
  policy_arn = each.value
}

data "aws_region" "current" {}

data "aws_serverlessapplicationrepository_application" "application" {
  application_id = "arn:aws:serverlessrepo:us-west-2:533243300146:applications/NewRelic-log-ingestion-s3"
}

resource "aws_serverlessapplicationrepository_cloudformation_stack" "stack" {
  name           = local.name
  application_id = data.aws_serverlessapplicationrepository_application.application.application_id
  capabilities   = data.aws_serverlessapplicationrepository_application.application.required_capabilities

  semantic_version = (
    var.application_version == ""
    ? data.aws_serverlessapplicationrepository_application.application.semantic_version
    : var.application_version
  )

  parameters = {
    NRLicenseKey = var.license_key
    NRLogType    = var.log_type
    FunctionRole = aws_iam_role.role.arn
  }
}

data "aws_lambda_function" "function" {
  depends_on = [
    aws_serverlessapplicationrepository_cloudformation_stack.stack,
  ]

  function_name = local.name
}
