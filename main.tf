terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-west-2"
}

resource "aws_s3_bucket" "data_bucket" {
  bucket = "json-scrapper"
  
}
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    effect    = "Allow"
    actions   = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

data "aws_iam_policy_document" "lambda_policy2" {
  statement {
    effect    = "Allow"
    actions   = [
        "s3:GetObject",
        "s3:PutObject"
      ]
    resources = ["${aws_s3_bucket.data_bucket.arn}/*"]
  }
}

data "aws_iam_policy_document" "lambda_policy3"{
  statement {
    effect = "Allow"
    actions = [
      "sns:Publish"
    ]
    resources = [aws_sns_topic.report_notification.arn]
  }
}

resource "aws_iam_policy" "s3_access" {
  name = "s3_access"
  policy = data.aws_iam_policy_document.lambda_policy2.json
}

resource "aws_iam_policy" "sns_publish_lambda" {
  name = "sns_publish_lambda"
  description = "Policy to allow Lambda to publish to SNS for email"
  policy = data.aws_iam_policy_document.lambda_policy3.json
}

resource "aws_iam_policy" "lambda_logging"{
  name   = "lambda_logging"
  policy = data.aws_iam_policy_document.lambda_policy.json
  
}
resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
  
}
resource "aws_iam_role_policy_attachment" "lambda_logs2" {
  role = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.s3_access.arn
  
}
resource "aws_iam_role_policy_attachment" "sns_publish_attachment" {
  role = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.sns_publish_lambda.arn
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.jsonParse.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.data_bucket.arn
}

resource "aws_lambda_function" "jsonParse" {
  filename      = "lambda.zip"
  function_name = "jsonParse"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "main.lambda_handler"
  runtime       = "python3.10"
}


resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.data_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.jsonParse.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".json"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

resource "aws_sns_topic" "report_notification"{
  name = "report_notification"
}

resource "aws_sns_topic_subscription" "email_notification" {
  topic_arn = aws_sns_topic.report_notification.arn
  protocol  = "email"
  endpoint  = "example@gmail.com" # Change to your desired email address
}
resource "aws_lambda_function_event_invoke_config" "email" {
  function_name = aws_lambda_function.jsonParse.arn

  destination_config {
    on_failure {
      destination = aws_sns_topic.report_notification.arn
    }
    on_success {
      destination = aws_sns_topic.report_notification.arn
    }
  }
}