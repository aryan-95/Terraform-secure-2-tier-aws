---
# Secure Two-Tier AWS Architecture with Monitoring, Audit, Backup & Automated Response

## 📌 Project Overview

This project demonstrates the deployment of a **secure two-tier AWS architecture** using **Terraform**. The infrastructure follows AWS best practices by separating the application and database layers into different subnets while implementing monitoring, auditing, backup, logging, automation, and secure administration.

The project provisions all AWS resources automatically using Infrastructure as Code (IaC) and fulfills the requirements of the CloudOps assignment.

---

## 🏗️ Architecture

```
Internet
    │
    ▼
┌─────────────────────────────────────────┐
│         Application Load Balancer        │
│   (public subnets: us-east-1a + 1b)     │
└─────────────────┬───────────────────────┘
                  │ HTTP (port 80)
                  ▼
┌─────────────────────────────────────────┐
│         EC2 App Server (Apache)          │  ← Public Subnet (us-east-1a)
│         CloudOps Dashboard              │
└─────────────────┬───────────────────────┘
                  │ MySQL (port 3306)
                  ▼
┌─────────────────────────────────────────┐
│         EC2 DB Server (MySQL)            │  ← Private Subnet (us-east-1a)
│         (no public access)              │
└─────────────────────────────────────────┘

Admin Access: SSM Session Manager only (no SSH, no bastion)
```


## 🚀 Features

* Infrastructure as Code (Terraform)
* Secure VPC Design
* Public and Private Subnets
* Internet Gateway & Route Tables
* Application Load Balancer (ALB)
* EC2 Application Server
* Private Database Server
* IAM Role with AWS Systems Manager (SSM)
* CloudWatch Monitoring & Alerts
* CloudWatch Log Groups
* CloudTrail Audit Logging
* EventBridge Event Monitoring
* SNS Email Notifications
* AWS Backup
* Lambda Cost Control Automation

---

# 🏗 Architecture

```
                 Internet
                     │
                     ▼
          Application Load Balancer
                     │
      ┌──────────────┴──────────────┐
      │                             │
      ▼                             ▼
 Public Subnet                Private Subnet
(App EC2 Instance)          (Database EC2/RDS)
      │                             │
      └──────────────┬──────────────┘
                     │
                   AWS VPC
```

Additional AWS Services:

* CloudWatch
* CloudTrail
* EventBridge
* SNS
* AWS Backup
* Lambda
* SSM Session Manager

---

# 📂 Project Structure

```
my-aws-project/
│
├── main.tf
├── vpc.tf
├── security_groups.tf
├── ec2.tf
├── alb.tf
├── cloudwatch.tf
├── cloudtrail.tf
├── eventbridge.tf
├── backup.tf
├── lambda.tf
│
└── lambda/
    ├── cost_control.py
    └── cost_control.zip
```

---

# ⚙ Technologies Used

* AWS
* Terraform
* Python
* Bash
* Apache HTTP Server
* AWS Lambda
* Amazon EC2
* Amazon VPC
* Amazon ALB
* CloudWatch
* CloudTrail
* EventBridge
* AWS Backup
* SNS
* IAM
* Systems Manager (SSM)

---

# 📋 AWS Resources Created

### Networking

* VPC
* Public Subnet
* Private Subnet
* Internet Gateway
* Route Tables
* Route Table Associations

### Security

* ALB Security Group
* Application Security Group
* Database Security Group
* IAM Roles
* IAM Instance Profile

### Compute

* Application EC2 Instance
* Database EC2 Instance

### Load Balancing

* Application Load Balancer
* Target Group
* Listener

### Monitoring

* CloudWatch Alarms
* CloudWatch Log Groups
* SNS Notifications

### Audit

* CloudTrail
* S3 Bucket for Logs

### Automation

* EventBridge Rules
* Lambda Function

### Backup

* Backup Vault
* Backup Plan
* Backup Selection

---

# 🔒 Security Features

* No SSH access
* Port 22 disabled
* Secure administration using SSM Session Manager
* Database isolated inside Private Subnet
* Database accessible only from Application Server
* ALB is the only public entry point
* IAM Least Privilege implementation
* CloudTrail auditing enabled

---

# 📊 Monitoring

CloudWatch monitors:

* CPU Utilization
* Memory Utilization
* Disk Utilization
* Instance Health
* Application Availability

Alerts are automatically sent through SNS Email.

---

# 📝 Logging

CloudWatch Log Groups:

```
/aws/ec2/application-access
/aws/ec2/application-error
/aws/ec2/system
```

---

# 🔍 Auditing

CloudTrail records management events including:

* RunInstances
* StopInstances
* TerminateInstances
* CreateUser
* DeleteBucket
* CreateSecurityGroup
* AuthorizeSecurityGroupIngress

Logs are stored securely inside an S3 Bucket.

---

# ⚡ EventBridge Automation

EventBridge detects:

* EC2 Launch
* EC2 Stop
* EC2 Termination
* IAM User Creation
* Security Group Changes
* S3 Bucket Deletion

Each event sends an SNS Email Notification.

---

# 💾 Backup Strategy

AWS Backup automatically creates backups for:

* Application EC2 EBS Volume
* Database Storage

Daily backup schedule with retention policy.

---

# 🤖 Cost Control Automation

Workflow:

```
RunInstances
      │
      ▼
 EventBridge
      │
      ▼
 Lambda Function
      │
      ▼
Checks Idle Time
      │
      ▼
Stops or Tags Instance
```

The Lambda function automatically stops or tags EC2 instances that remain unused for more than **10 minutes**.

---

# 🌐 Sample Application

The application server automatically installs Apache during provisioning and hosts a **CloudOps Monitoring Dashboard** using EC2 User Data.

The application is accessible only through the Application Load Balancer DNS.

---

# 🛠 Installation

Clone the repository

```bash
git clone <repository-url>
cd my-aws-project
```

Initialize Terraform

```bash
terraform init
```

Validate configuration

```bash
terraform validate
```

Preview infrastructure

```bash
terraform plan
```

Deploy infrastructure

```bash
terraform apply
```

Destroy infrastructure

```bash
terraform destroy
```

---

# 📷 Expected AWS Console Resources

After deployment the following services should appear:

* VPC
* Public Subnet
* Private Subnet
* Internet Gateway
* Route Tables
* Security Groups
* EC2 Instances
* Application Load Balancer
* Target Group
* IAM Roles
* CloudWatch
* CloudTrail
* EventBridge
* Lambda
* SNS
* AWS Backup
* S3 Bucket

---

# 📚 Learning Outcomes

This project demonstrates practical experience with:

* Infrastructure as Code
* AWS Networking
* Secure Cloud Architecture
* Monitoring & Logging
* Event-Driven Automation
* Backup & Disaster Recovery
* Cloud Security Best Practices
* AWS Cost Optimization

---

## 👤 Author

**Aryan Paswan**
- DevOps & Cloud Engineering Student
- Focus: AWS | Terraform | CI/CD | Devops

---

# 📄 License

This project was developed for educational purposes as part of a CloudOps Internship Assignment.
