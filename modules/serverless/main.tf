# Create the DynamoDB Table
resource "aws_dynamodb_table" "app_table" {
  name           = "${var.environment}-app-table"
  billing_mode   = "PAY_PER_REQUEST" # Serverless billing
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

# Package the Python code into a ZIP file for AWS
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/src/index.py"
  output_path = "${path.module}/lambda.zip"
}

# Create the IAM Role for Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "${var.environment}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# Attach basic execution permissions (CloudWatch logs)
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Create the Lambda Function
resource "aws_lambda_function" "api_handler" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "${var.environment}-api-handler"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "index.handler"
  runtime       = "python3.9"
}

# Create the HTTP API Gateway
resource "aws_apigatewayv2_api" "http_api" {
  name          = "${var.environment}-http-api"
  protocol_type = "HTTP"
}

# Connect the API Gateway to the Lambda Function
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.api_handler.invoke_arn
}

# Define the routing path (e.g., GET /hello)
resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /hello"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}