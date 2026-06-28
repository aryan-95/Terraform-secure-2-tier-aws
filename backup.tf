resource "aws_iam_role" "backup_role" {
  name = "Aryan_aws-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "Aryan_aws-backup-role"
  }
}

resource "aws_iam_role_policy_attachment" "backup_policy" {
  role       = aws_iam_role.backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}


resource "aws_backup_vault" "main" {
  name = "project-backup-vault"

  tags = {
    Name = "Aryan_project-backup-vault"
  }
}


resource "aws_backup_plan" "main" {
  name = "project-backup-plan"

  rule {
    rule_name         = "daily-backup"
    target_vault_name = aws_backup_vault.main.name
    schedule          = "cron(0 12 * * ? *)"

    lifecycle {
      delete_after = 7
    }
  }

  tags = {
    Name = "Aryan_project-backup-plan"
  }
}

resource "aws_backup_selection" "app_server_backup" {
  name         = "app-server-backup"
  plan_id      = aws_backup_plan.main.id
  iam_role_arn = aws_iam_role.backup_role.arn

  resources = [
    aws_instance.app_server.arn
  ]
}


resource "aws_backup_selection" "db_server_backup" {
  name         = "db-server-backup"
  plan_id      = aws_backup_plan.main.id
  iam_role_arn = aws_iam_role.backup_role.arn

  resources = [
    aws_instance.db_server.arn
  ]
}