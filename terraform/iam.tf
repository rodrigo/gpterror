resource "aws_iam_policy" "put_metric_data" {
  name        = "GPTerrorPutCloudWatchMetricData"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "cloudwatch:PutMetricData",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_policy" "s3_access" {
  name        = "GPTerrorS3Access"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject",
          "s3:PutObject"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::rebelatto/gpterror/stories/*",
          "arn:aws:s3:::rebelatto"
        ]
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "ec2_metrics" {
  name       = "put_metric_data_attachment"
  roles      = [aws_iam_role.ec2.name, aws_iam_role.lambda.name]
  policy_arn = aws_iam_policy.put_metric_data.arn
}

resource "aws_iam_policy_attachment" "ec2_s3_access" {
  name       = "s3_access_attachment"
  roles      = [aws_iam_role.ec2.name, aws_iam_role.lambda.name]
  policy_arn = aws_iam_policy.s3_access.arn
}

resource "aws_iam_role" "ec2" {
  name = "gpterror_asg_ec2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "launch_template" {
  name = "gpterror_launch_template"
  role = aws_iam_role.ec2.name
}

resource "aws_iam_role" "lambda" {
  name = "gpterror_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:us-east-1:${data.aws_caller_identity.current.account_id}:${aws_apigatewayv2_api.this.id}/*/*/"
}
