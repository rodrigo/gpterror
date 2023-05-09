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
          "arn:aws:s3:::rebelatto/certs/.well-known/acme-challenge/*",
          "arn:aws:s3:::rebelatto/certs/.well-known/acme-challenge",
          "arn:aws:s3:::rebelatto/certs/*",
          "arn:aws:s3:::rebelatto/gpterror/stories/*",
          "arn:aws:s3:::rebelatto"
        ]
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "metrics" {
  name       = "put_metric_data_attachment"
  roles      = [aws_iam_role.ec2.name, aws_iam_role.lambda.name]
  policy_arn = aws_iam_policy.put_metric_data.arn
}

resource "aws_iam_policy_attachment" "s3_access" {
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
  name = "lambda"

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

resource "aws_lambda_permission" "apigw_lambda_gpterror" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.gpterror.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:us-east-1:${data.aws_caller_identity.current.account_id}:${aws_apigatewayv2_api.this.id}/*/*/"
}

resource "aws_s3_bucket_policy" "cloudfront_access" {
  bucket = data.aws_s3_bucket.this.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowCloudFrontServicePrincipal"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action = "s3:GetObject"
        Effect   = "Allow"
        Resource = "arn:aws:s3:::rebelatto/certs/.well-known/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.this.arn
          }
        }
      },
    ]
  })
}
