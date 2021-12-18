# Output value definitions

output "MyLambdaBucket_name" {
  description = "S3 bucket name for Lambda function"
  value       = aws_s3_bucket.MyLambdaBucket.id
}

output "MyLambdaFunction_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.MyLambdaFunction.function_name
}

output "MyAPIGateway_url" {
  description = "URL for API Gateway"
  value       = aws_apigatewayv2_stage.MyAPIGatewayStage.invoke_url
}