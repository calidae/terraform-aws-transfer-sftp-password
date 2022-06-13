
resource "aws_s3_bucket" "input" {}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.input.id
  acl    = "private"
}

resource "aws_transfer_server" "sftp" {
  identity_provider_type = "AWS_LAMBDA"
  function               = aws_lambda_function.sftp_auth.arn
}

data "aws_iam_policy_document" "assume_role_from_transfer" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["transfer.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "sftp" {
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
  ]
  assume_role_policy = data.aws_iam_policy_document.assume_role_from_transfer.json
}

data "aws_iam_policy_document" "assume_role_from_lambda" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "sftp_auth" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_from_lambda.json
}

data "archive_file" "sftp_auth" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/sftp_auth"
  output_path = "${path.module}/lambda/sftp_auth.zip"
}

resource "random_password" "sftp_password" {
  length  = var.sftp_password_length
  special = false
}

resource "random_pet" "lambda_auth_name" {
  length    = 4
  prefix    = "transfer-authentication"
  separator = "-"
}

resource "aws_lambda_function" "sftp_auth" {
  filename         = data.archive_file.sftp_auth.output_path
  function_name    = random_pet.lambda_auth_name.id
  role             = aws_iam_role.sftp_auth.arn
  handler          = "index.lambda_handler"
  timeout          = 60
  source_code_hash = filebase64sha256(data.archive_file.sftp_auth.output_path)

  runtime = "python3.9"

  environment {
    variables = {
      TRANSFER_PASSWORD       = random_password.sftp_password.result
      TRANSFER_ROLE           = aws_iam_role.sftp.arn
      TRANSFER_HOME_DIRECTORY = "/${aws_s3_bucket.input.id}/"
    }
  }
}

resource "aws_lambda_permission" "sftp_auth" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sftp_auth.function_name
  principal     = "transfer.amazonaws.com"
  source_arn    = aws_transfer_server.sftp.arn
}
