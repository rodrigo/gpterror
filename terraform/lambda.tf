data "archive_file" "gpterror" {
  type        = "zip"
  source_dir = "lambda_files"
  excludes    = ["payload.zip"]
  output_path = "lambda_files/payload.zip"
}

resource "aws_lambda_function" "gpterror" {
  filename      = "lambda_files/payload.zip"
  function_name = "gpterror"
  role          = aws_iam_role.lambda.arn
  handler       = "function.lambda_handler"
  source_code_hash = data.archive_file.gpterror.output_base64sha256
  runtime = "python3.7"
}
