# TODO: Define the variable for aws_region

variable "aws_region" {
  description = "Variable for the AWS region"
  type = string
  default = "us-east-1"
}

variable "function_name" {
    description = "Name of the lambda function"
    type        = string
    default     = "greet_function"
}

variable "function_runtime" {
    description = "The runtime for the lambda function"
    type        = string
    default     = "python3.9"
}

variable "handler" {
    description = "The lambda handler"
    type        = string
    default     = "greet_lambda.lambda_handler"
}

variable "zip_file" {
    description = "Name of zip file"
    type        = string
    default     = "lambda.zip"
}

variable "source_file" {
    description = "Name of source file"
    type        = string
    default     = "greet_lambda.py"
}

