resource "aws_cloudwatch_event_rule" "ec2_launched" {
  name        = "Aryan_ec2-instance-launched"
  description = "Trigger when EC2 instance is launched"

  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      eventName = ["RunInstances"]
    }
  })
}

resource "aws_cloudwatch_event_target" "ec2_launched_target" {
  rule      = aws_cloudwatch_event_rule.ec2_launched.name
  target_id = "ec2-launched-sns"
  arn       = aws_sns_topic.alerts.arn
}


resource "aws_cloudwatch_event_rule" "ec2_stopped" {
  name        = "Aryan_ec2-instance-stopped"
  description = "Trigger when EC2 instance is stopped"

  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      eventName = ["StopInstances"]
    }
  })
}

resource "aws_cloudwatch_event_target" "ec2_stopped_target" {
  rule      = aws_cloudwatch_event_rule.ec2_stopped.name
  target_id = "ec2-stopped-sns"
  arn       = aws_sns_topic.alerts.arn
}

resource "aws_cloudwatch_event_rule" "ec2_terminated" {
  name        = "Aryan_ec2-instance-terminated"
  description = "Trigger when EC2 instance is terminated"

  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      eventName = ["TerminateInstances"]
    }
  })
}

resource "aws_cloudwatch_event_target" "ec2_terminated_target" {
  rule      = aws_cloudwatch_event_rule.ec2_terminated.name
  target_id = "ec2-terminated-sns"
  arn       = aws_sns_topic.alerts.arn
}


resource "aws_cloudwatch_event_rule" "iam_user_created" {
  name        = "iam-user-created"
  description = "Trigger when IAM user is created"

  event_pattern = jsonencode({
    source      = ["aws.iam"]
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      eventName = ["CreateUser"]
    }
  })
}

resource "aws_cloudwatch_event_target" "iam_user_created_target" {
  rule      = aws_cloudwatch_event_rule.iam_user_created.name
  target_id = "iam-user-created-sns"
  arn       = aws_sns_topic.alerts.arn
}


resource "aws_cloudwatch_event_rule" "sg_rule_changed" {
  name        = "security-group-rule-changed"
  description = "Trigger when security group rule is changed"

  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      eventName = ["AuthorizeSecurityGroupIngress", "AuthorizeSecurityGroupEgress", "RevokeSecurityGroupIngress", "RevokeSecurityGroupEgress"]
    }
  })
}

resource "aws_cloudwatch_event_target" "sg_rule_changed_target" {
  rule      = aws_cloudwatch_event_rule.sg_rule_changed.name
  target_id = "sg-rule-changed-sns"
  arn       = aws_sns_topic.alerts.arn
}


resource "aws_cloudwatch_event_rule" "s3_bucket_deleted" {
  name        = "s3-bucket-deleted"
  description = "Trigger when S3 bucket is deleted"

  event_pattern = jsonencode({
    source      = ["aws.s3"]
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      eventName = ["DeleteBucket"]
    }
  })
}

resource "aws_cloudwatch_event_target" "s3_bucket_deleted_target" {
  rule      = aws_cloudwatch_event_rule.s3_bucket_deleted.name
  target_id = "s3-bucket-deleted-sns"
  arn       = aws_sns_topic.alerts.arn
}


resource "aws_sns_topic_policy" "alerts_policy" {
  arn = aws_sns_topic.alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEventBridgePublish"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = "sns:Publish"
        Resource = aws_sns_topic.alerts.arn
      }
    ]
  })
}