output "lambda_function_arn" {
  value = data.aws_lambda_function.function.arn
}

output "lambda_function_name" {
  value = data.aws_lambda_function.function.function_name
}
