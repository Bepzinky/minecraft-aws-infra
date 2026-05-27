variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "ami_id" {
  type        = string
  description = "Amazon Linux 2 AMI ID"
  default     = "ami-0c02fb55956c7d316"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.large"
}

variable "key_name" {
  type        = string
  description = "Name of the EC2 key pair used for SSH admin access"
}

variable "my_ip" {
  type        = string
  description = "Your public IP"
}

variable "ecr_repo_url" {
  type        = string
  description = "Full ECR repository URL"
}

variable "s3_bucket" {
  type        = string
  description = "S3 bucket name for backups"
}
