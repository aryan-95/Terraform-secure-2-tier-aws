resource "aws_iam_role" "lambda_role" {
  name = "Aryan_lambda-cost-control-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "Aryan_lambda-cost-control-role"
  }
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda-cost-control-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:StopInstances",
          "ec2:CreateTags"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_function" "cost_control" {
  function_name    = "Aryan_cost-control-lambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "python3.12"
  timeout          = 60
  filename         = "${path.module}/lambda/cost_control.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/cost_control.zip")

  environment {
    variables = {
      IDLE_MINUTES = "10"
    }
  }

  tags = {
    Name = "Aryan_cost-control-lambda"
  }
}

resource "aws_cloudwatch_event_rule" "ec2_launch_trigger" {
  name        = "ec2-launch-trigger"
  description = "Trigger Lambda when new EC2 instance is launched"

  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      eventName = ["RunInstances"]
    }
  })
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.ec2_launch_trigger.name
  target_id = "cost-control-lambda"
  arn       = aws_lambda_function.cost_control.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cost_control.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ec2_launch_trigger.arn
}