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
  integration_uri  = aws_lambda_function.this.invoke_arn
}

resource "aws_apigatewayv2_route" "get" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "GET /"
  target = "integrations/${aws_apigatewayv2_integration.lambda.id}"

}

resource "aws_acm_certificate" "cert" {
  private_key      = file("certs/www_key")
  certificate_body = file("certs/www_ca")
}

resource "aws_api_gateway_domain_name" "gpterror" {
  regional_certificate_arn = aws_acm_certificate.cert.arn
  domain_name = local.var.domain_name
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_apigatewayv2_api_mapping" "gpterror" {
  api_id      = aws_apigatewayv2_api.this.id
  domain_name = aws_api_gateway_domain_name.gpterror.id
  stage       = aws_apigatewayv2_stage.this.id
}
