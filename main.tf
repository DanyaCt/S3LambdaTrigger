terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "bucket-for-lambda-task123"
}

resource "aws_iam_role" "lambda_iam" {
  name = "LambdaRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "revoke_keys_role_policy" {
  name = "AllowS3Policy"
  role = aws_iam_role.lambda_iam.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*",
        "ses:*",
        "logs:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

data "archive_file" "zip" {
  type = "zip"
  source_file = "function.py"
  output_path = "function.zip"
}

resource "aws_lambda_function" "test_lambda" {
  filename      = "${data.archive_file.zip.output_path}"
  function_name = "LambdaError"
  role          = aws_iam_role.lambda_iam.arn
  source_code_hash = "${data.archive_file.zip.output_base64sha256}"
  handler          = "function.lambda_handler"
  runtime = "python3.9"
}

resource "aws_s3_bucket_notification" "aws-lambda-trigger" {
  bucket = aws_s3_bucket.bucket.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.test_lambda.arn
    events              = ["s3:ObjectCreated:*"]

  }
}
resource "aws_lambda_permission" "test" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${aws_s3_bucket.bucket.id}"
}

resource "aws_cloudwatch_log_metric_filter" "yada" {
  name           = "MyLambdaErrorCount"
  pattern        = "?ERROR ?Error ?error"
  log_group_name = aws_cloudwatch_log_group.loggroup.name

  metric_transformation {
    name      = "EventCount"
    namespace = "YourNamespace"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_group" "loggroup" {
  name = "/aws/lambda/LambdaError"
}

resource "aws_cloudwatch_metric_alarm" "MyErrorAlarm" {
  alarm_name                = "ErrorAlarm"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "EventCount"
  namespace                 = "YourNamespace"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "0"
  alarm_description         = "This metric monitors error log in S3"
  insufficient_data_actions = []
}