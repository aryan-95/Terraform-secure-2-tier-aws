# SNS Topic
resource "aws_sns_topic" "alerts" {
  name = "Aryan-project-Alerts"
}

# SNS Email Subscription
resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "aryanpaswan801@gmail.com"
}

# CPU Alarm
resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "Aryan-cpu-utilization-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "EC2 CPU utilization exceeded 80%"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    InstanceId = aws_instance.app_server.id
  }
}

# Memory Alarm
resource "aws_cloudwatch_metric_alarm" "memory_alarm" {
  alarm_name          = "Aryan-memory-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = 120
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Memory utilization exceeded 80%"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    InstanceId = aws_instance.app_server.id
  }
}

# Disk Alarm
resource "aws_cloudwatch_metric_alarm" "disk_alarm" {
  alarm_name          = "Aryan-disk-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "disk_used_percent"
  namespace           = "CWAgent"
  period              = 120
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Disk utilization exceeded 80%"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    InstanceId = aws_instance.app_server.id
    path       = "/"
    fstype     = "xfs"
  }
}

# Status Check Alarm
resource "aws_cloudwatch_metric_alarm" "status_check_alarm" {
  alarm_name          = "Aryan-instance-status-check-failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "EC2 status check failed"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    InstanceId = aws_instance.app_server.id
  }
}

# Log Group - Access Logs
resource "aws_cloudwatch_log_group" "access_logs" {
  name              = "/aws/ec2/application-access"
  retention_in_days = 7

  tags = {
    Name = "Aryan-application-access-logs"
  }
}


resource "aws_cloudwatch_log_group" "error_logs" {
  name              = "/aws/ec2/application-error"
  retention_in_days = 7

  tags = {
    Name = "Aryan-application-error-logs"
  }
}

# Log Group - System Logs
resource "aws_cloudwatch_log_group" "system_logs" {
  name              = "/aws/ec2/system"
  retention_in_days = 7

  tags = {
    Name = "Aryan-system-logs"
  }
}