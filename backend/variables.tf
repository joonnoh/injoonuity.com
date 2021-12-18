# Input variable definitions

variable "aws_region" {
  description = "AWS region for all resources"
  default     = "us-east-1"
}

variable "MyTable_name" {
  description = "DynamoDB table name (space is not allowed)"
  default     = "InjoonuityTable"
}

variable "MyTable_billing_mode" {
  description = "Controls how you are charged for read and write throughput and how you manage capacity."
  default     = "PAY_PER_REQUEST"
}

variable "MyEnvironment" {
  description = "Name of environment"
  default     = "InjoonuityTest"
}

variable "MyLambdaBucket_prefix" {
  description = "Prefix for S3 bucket of Lambda function"
  default     = "injoonuity-lambda-bucket"
}

variable "MyLambdaDirectory_source_dir" {
  description = "Local directory of Lambda file"
  default     = "VisitorCountLambda"
}

variable "MyLambdaFunction_name" {
  description = "Name of the Lambda function"
  default     = "VisitorCountLambda"
}

variable "MyLambdaFunction_runtime" {
  description = "Runtime of the Lambda function"
  default     = "python3.9"
}

variable "MyLambdaFunction_handler" {
  description = "Handler of the Lambda function"
  default     = "VisitorCount.lambda_handler"
}

variable "MyLambdaRole_name" {
  description = "Name of the Lambda role"
  default     = "VisitorCountLambdaRole"
}

variable "MyLambdaPolicy_name" {
  description = "Name of the Lambda IAM policy"
  default     = "VisitorCountLambdaPolicy"
}

variable "MyAPIGateway_name" {
  description = "Name of the API Gateway"
  default     = "InjoonuityAPI"
}

variable "MyAPIGatewayStage_name" {
  description = "Name of the API Gateway stage"
  default     = "InjoonuityAPIStage"
}