resource "aws_s3_bucket" "b" {
  bucket = "meet-lambda-bucket"

  tags = {
    Name        = "meet-lambda-bucket"
    Environment = "Dev"
  }
}

resource "aws_lambda_function" "meet_lambda" {
    function_name = "MeetLambda"

    s3_bucket = "meet-lambda-bucket"
    s3_key    = "practice.zip"

    handler = "main.handler"
    runtime = "python3.8"

    role = "${aws_iam_role.lambda_exec.arn}"
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_example_lambda"

  assume_role_policy = <<EOF
{
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
}
EOF
}