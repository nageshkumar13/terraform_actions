variable "aws_region" {
  description = "AWS region where resources will be created."
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type for the application server."
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "Optional AMI ID override. When set, Terraform skips the SSM parameter lookup and uses this AMI directly."
  type        = string
  default     = ""
}

variable "instance_name" {
  description = "Name tag applied to the EC2 instance."
  type        = string
  default     = "terraform-actions-server"
}

variable "security_group_name" {
  description = "Name of the security group attached to the instance."
  type        = string
  default     = "terraform-actions-sg"
}

variable "repo_url" {
  description = "Public Git repository URL that EC2 should clone."
  type        = string
  default     = "https://github.com/nageshkumar13/terraform_actions.git"
}

variable "repo_branch" {
  description = "Git branch the EC2 bootstrap script should check out."
  type        = string
  default     = "main"
}

variable "app_directory" {
  description = "Absolute path on the EC2 host where the repository will be cloned."
  type        = string
  default     = "/opt/terraform_actions"
}

variable "container_name" {
  description = "Docker container name for the FastAPI application."
  type        = string
  default     = "terraform-actions-app"
}

variable "container_port" {
  description = "Port exposed by the FastAPI container."
  type        = number
  default     = 8000
}

variable "host_port" {
  description = "Port exposed on the EC2 host for browser access."
  type        = number
  default     = 80
}

variable "http_ingress_cidr" {
  description = "CIDR range allowed to reach the application in the browser."
  type        = string
  default     = "0.0.0.0/0"
}

variable "tags" {
  description = "Additional tags to apply to AWS resources."
  type        = map(string)
  default     = {}
}
