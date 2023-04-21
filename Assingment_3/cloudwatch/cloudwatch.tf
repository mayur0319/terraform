resource "aws_cloudwatch_log_group" "api_gateway_logs" {
  name = "/aws/api-gateway/my-api-logs"
}

data "aws_iam_policy_document" "cloudwatch_logs" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    effect = "Allow"

    resources = [
      "${aws_cloudwatch_log_group.api_gateway_logs.arn}",
    ]
  }
}