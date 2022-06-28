

provider "aws" {
    # https://registry.terraform.io/providers/hashicorp/aws/latest/docs
    profile = "default"
    region  = var.aws_region
}

resource "aws_iam_role" "greet_lambda_role" {
    # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
    name = "iam_role_for_greet_lambda"

    assume_role_policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
            }
        ]
    })
}

resource "aws_iam_role_policy" "greet_lambda_policy" {
    # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy
    name   = "greet_lambda_iam_role_policy"
    role   = "${aws_iam_role.greet_lambda_role.id}"

    policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "ec2:DeleteNetworkInterface",
                    "ec2:DescribeNetworkInterfaces",
                    "ec2:CreateNetworkInterface"
                ],
                "Resource": "*"
            }
        ]
    })
}

resource "aws_iam_policy" "lambda_logging" {
    # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy
    name        = "lambda_logging"
    path        = "/"
    description = "Lambda Logging Policy"

    policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": [
                    "logs:PutLogEvents",
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream"
                ],
                "Resource": "arn:aws:logs:*:*:*",
                "Effect": "Allow"
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "greet_logs" {
    # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
    policy_arn = aws_iam_policy.lambda_logging.arn
    role       = aws_iam_role.greet_lambda_role.name
}

resource "aws_cloudwatch_log_group" "greet_log_group" {
    # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group
    name              = "/aws/lambda/${var.function_name}"
    retention_in_days = 1
}

resource "aws_vpc" "greet_vpc" {
    # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "Greet_VPC"
    }
}

resource "aws_subnet" "greet_subnet" {
    # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
    vpc_id     = aws_vpc.greet_vpc.id
    cidr_block = "10.0.1.0/24"
    tags = {
        Name = "Greet_Subnet"
    }
}

resource "aws_security_group" "greet_security_group" {
    # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
    name        = "greet_security_group"
    vpc_id      = aws_vpc.greet_vpc.id
    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1" # all
        cidr_blocks      = ["0.0.0.0/0"]
    }
    tags = {
        Name = "GreetLambda_Security_Group"
    }
}

data "archive_file" "greet_lambda" {
    # https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/archive_file
    type = "zip"
    source_file = "${path.module}/${var.source_file}"
    output_path = "${path.module}/${var.zip_file}"
}

resource "aws_lambda_function" "greet_lambda_function" {
    # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function
    function_name = var.function_name
    runtime       = var.function_runtime
    handler       = var.handler
    filename      = var.zip_file
    role          = aws_iam_role.greet_lambda_role.arn

    vpc_config {
        subnet_ids         = [ aws_subnet.greet_subnet.id ]
        security_group_ids = [ aws_security_group.greet_security_group.id ]
    }

    depends_on = [
        aws_cloudwatch_log_group.greet_log_group,
        aws_iam_role_policy_attachment.greet_logs
    ]

    environment {
        variables = {
            greeting = "Hello and Welcome"
        }
    }
}
