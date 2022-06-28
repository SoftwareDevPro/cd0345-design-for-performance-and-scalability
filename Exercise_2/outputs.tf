# TODO: Define the output variable for the lambda function.

# https://www.terraform.io/language/values/outputs
output "greet_lambda_last_modified" {
  description = "Date lambda was last modified"
  value       = aws_lambda_function.greet_lambda_function.last_modified
  sensitive   = false  
}

output "greet_lambda_version" {
  description = "Version of the lambda function"
  value       = aws_lambda_function.greet_lambda_function.version
  sensitive   = false
}

output "greet_lambda_arn" {
  description = "ARN of the function"
  value       = aws_lambda_function.greet_lambda_function.arn
  sensitive   = false
}

output "greet_lambda_source_code_size" {
  description = "Size in bytes of the lambda function zip file"
  value       = aws_lambda_function.greet_lambda_function.source_code_size
  sensitive   = false
}

