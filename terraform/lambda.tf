data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda_files/function.py"
  output_path = "lambda_files/payload.zip"
}

resource "aws_lambda_function" "this" {
  filename      = "lambda_files/payload.zip"
  function_name = "gpterror"
  role          = aws_iam_role.lambda.arn
  handler       = "function.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.7"
}
