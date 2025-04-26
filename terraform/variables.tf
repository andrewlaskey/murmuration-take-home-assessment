variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for public subnet 1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for public subnet 2"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_1_cidr" {
  description = "CIDR block for private subnet 1"
  type        = string
  default     = "10.0.3.0/24"
}

variable "private_subnet_2_cidr" {
  description = "CIDR block for private subnet 2"
  type        = string
  default     = "10.0.4.0/24"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage for RDS instance (in GB)"
  type        = number
  default     = 20
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}

variable "db_multi_az" {
  description = "Enable Multi-AZ for RDS instance"
  type        = bool
  default     = false
}

variable "backend_task_cpu" {
  description = "CPU units for backend task"
  type        = string
  default     = "256"
}

variable "backend_task_memory" {
  description = "Memory for backend task (in MiB)"
  type        = string
  default     = "512"
}

variable "frontend_task_cpu" {
  description = "CPU units for frontend task"
  type        = string
  default     = "256"
}

variable "frontend_task_memory" {
  description = "Memory for frontend task (in MiB)"
  type        = string
  default     = "512"
}

variable "backend_service_count" {
  description = "Number of backend tasks to run"
  type        = number
  default     = 2
}

variable "frontend_service_count" {
  description = "Number of frontend tasks to run"
  type        = number
  default     = 2
}

variable "my_ip" {
  description = "Your IP address for SSH access"
  type        = string
  default     = "0.0.0.0"
}