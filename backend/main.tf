# main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 1.1.0"
}

provider "aws" {
  profile = "default"
  region  = var.aws_region
}

resource "aws_dynamodb_table" "MyTable" {
  name         = var.MyTable_name
  billing_mode = var.MyTable_billing_mode
  hash_key     = "ItemName"
  attribute {
    name = "ItemName"
    type = "S"
  }
  tags = {
    environment = var.MyEnvironment
  }
}

resource "aws_s3_bucket" "MyLambdaBucket" {
  bucket_prefix = var.MyLambdaBucket_prefix
  acl           = "private"
  force_destroy = true
  tags = {
    environment = var.MyEnvironment
  }
}

data "archive_file" "MyLambdaDirectory" {
  type        = "zip"
  source_dir  = "${path.module}/${var.MyLambdaDirectory_source_dir}"
  output_path = "${path.module}/${var.MyLambdaDirectory_source_dir}.zip"
}

resource "aws_s3_bucket_object" "MyLambdaBucketObject" {
  bucket = aws_s3_bucket.MyLambdaBucket.id
  key    = "${var.MyLambdaDirectory_source_dir}.zip"
  source = data.archive_file.MyLambdaDirectory.output_path
  etag   = filemd5(data.archive_file.MyLambdaDirectory.output_path)
}

resource "aws_lambda_function" "MyLambdaFunction" {
  function_name    = var.MyLambdaFunction_name
  s3_bucket        = aws_s3_bucket.MyLambdaBucket.id
  s3_key           = aws_s3_bucket_object.MyLambdaBucketObject.key
  runtime          = var.MyLambdaFunction_runtime
  handler          = var.MyLambdaFunction_handler
  source_code_hash = data.archive_file.MyLambdaDirectory.output_base64sha256
  role             = aws_iam_role.MyLambdaRole.arn
  environment {
    variables = {
      DBtable = aws_dynamodb_table.MyTable.name
    }
  }
}

resource "aws_cloudwatch_log_group" "MyLambdaLogs" {
  name              = "/aws/lambda/${aws_lambda_function.MyLambdaFunction.function_name}"
  retention_in_days = 7
}

resource "aws_iam_role" "MyLambdaRole" {
  name = var.MyLambdaRole_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "MyLambdaRoleAttachment" {
  role       = aws_iam_role.MyLambdaRole.name
  policy_arn = aws_iam_policy.MyLambdaPolicy.arn
}

resource "aws_iam_policy" "MyLambdaPolicy" {
  name        = var.MyLambdaPolicy_name
  description = "IAM policy to allow read and write to DynamoDB and Cloudwatch logs"
  policy      = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [ 
        "dynamodb:BatchGetItem",
        "dynamodb:GetItem",
        "dynamodb:Scan",
        "dynamodb:Query",
        "dynamodb:BatchWriteItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem"
      ],
      "Resource": "${aws_dynamodb_table.MyTable.arn}"
    }
  ]
}
EOT
}

resource "aws_apigatewayv2_api" "MyAPIGateway" {
  name          = var.MyAPIGateway_name
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "MyAPIGatewayStage" {
  api_id      = aws_apigatewayv2_api.MyAPIGateway.id
  name        = var.MyAPIGatewayStage_name
  auto_deploy = true
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.MyAPIGatewayLogs.arn
    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
    })
  }
}

resource "aws_apigatewayv2_integration" "MyAPIGatewayIntegration" {
  api_id             = aws_apigatewayv2_api.MyAPIGateway.id
  integration_uri    = aws_lambda_function.MyLambdaFunction.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "MyAPIGatewayRoute" {
  api_id    = aws_apigatewayv2_api.MyAPIGateway.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.MyAPIGatewayIntegration.id}"
}

resource "aws_cloudwatch_log_group" "MyAPIGatewayLogs" {
  name              = "/aws/api_gw/${aws_apigatewayv2_api.MyAPIGateway.name}"
  retention_in_days = 7
}

resource "aws_lambda_permission" "MyAPIGatewayPermission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.MyLambdaFunction.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.MyAPIGateway.execution_arn}/*/*"
}