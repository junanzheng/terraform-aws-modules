data "archive_file" "this" {
  type        = "zip"
  output_path = "${path.module}/deploy.zip"
  source_dir = "${path.module}/nodejs"
}

# Define lambda function to request slack endpoint
resource "aws_lambda_function" "health_check_slack_notification_lambda" {
  provider = "aws.virginia"

  function_name = "${replace("${var.domen_name}${var.resource_path}", "/[./]+/", "-")}-slack"
  filename = "${path.module}/deploy.zip"
  source_code_hash = data.archive_file.this.output_base64sha256
  handler = "index.handler"
  runtime = "nodejs12.x"
  role = aws_iam_role.iam_for_lambda_health_check.arn
  memory_size = 1024
  timeout = 5

  environment {
    variables = {
      hook_url = var.slack_hook_url
    }
  }
}