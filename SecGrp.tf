resource "aws_security_group" "alb_sg" {
  name        = "Aryan-alb-sg"
  vpc_id      = aws_vpc.main.id
  description = "Allow http from internet"

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Aryan-alb-sg"
  }
}

resource "aws_security_group" "app_sg" {
  name        = "Aryan-appServer-sg"
  vpc_id      = aws_vpc.main.id
  description = "Allow http from ALB only"

  ingress {
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
    from_port       = 80
    to_port         = 80
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Aryan-app-sg"
  }
}

resource "aws_security_group" "db_sg" {
  name        = "Aryan-DB-sg"
  vpc_id      = aws_vpc.main.id
  description = "Allow traffic only from app server"

  ingress {
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
    from_port       = 3306
    to_port         = 3306
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Aryan-DB-sg"
  }
}