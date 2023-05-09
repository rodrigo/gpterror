resource "aws_apigatewayv2_api" "this" {
  name          = "gpterror"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "this" {
  api_id = aws_apigatewayv2_api.this.id
  auto_deploy = true
  name   = "$default"
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id           = aws_apigatewayv2_api.this.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.gpterror.invoke_arn
}

resource "aws_apigatewayv2_route" "get" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "GET /"
  target = "integrations/${aws_apigatewayv2_integration.lambda.id}"

}
