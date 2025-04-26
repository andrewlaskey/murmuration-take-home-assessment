provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket = "survey-terraform-state"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# VPC Configuration
resource "aws_vpc" "survey_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "survey-vpc"
  }
}

# Create public subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.survey_vpc.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "survey-public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.survey_vpc.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags = {
    Name = "survey-public-subnet-2"
  }
}

# Create private subnets for RDS and ECS tasks
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.survey_vpc.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "survey-private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.survey_vpc.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "survey-private-subnet-2"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "survey_igw" {
  vpc_id = aws_vpc.survey_vpc.id

  tags = {
    Name = "survey-igw"
  }
}

# Route Table for public subnets
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.survey_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.survey_igw.id
  }

  tags = {
    Name = "survey-public-rt"
  }
}

# Associate route table with public subnets
resource "aws_route_table_association" "public_rta_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rta_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

# Route table for private subnets
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.survey_vpc.id

  tags = {
    Name = "survey-private-rt"
  }
}

# Associate route table with private subnets
resource "aws_route_table_association" "private_rta_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rta_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt.id
}

# NAT Gateway for private subnets
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  depends_on = [aws_internet_gateway.survey_igw]

  tags = {
    Name = "survey-nat-eip"
  }
}

resource "aws_nat_gateway" "survey_nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id
  depends_on    = [aws_internet_gateway.survey_igw]

  tags = {
    Name = "survey-nat-gateway"
  }
}

# Add route to NAT Gateway for private subnets
resource "aws_route" "private_nat_route" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.survey_nat.id
}

# Security Group for ALB
resource "aws_security_group" "alb_sg" {
  name        = "survey-alb-sg"
  description = "Security group for survey application ALB"
  vpc_id      = aws_vpc.survey_vpc.id

  # Allow HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound connections
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "survey-alb-sg"
  }
}

# Security Group for ECS Tasks
resource "aws_security_group" "ecs_sg" {
  name        = "survey-ecs-sg"
  description = "Security group for survey application ECS tasks"
  vpc_id      = aws_vpc.survey_vpc.id

  # Allow traffic from ALB security group
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Allow outbound connections
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "survey-ecs-sg"
  }
}

# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "survey-rds-sg"
  description = "Security group for survey application RDS instance"
  vpc_id      = aws_vpc.survey_vpc.id

  # Allow PostgreSQL connection from ECS security group
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_sg.id]
  }

  # Allow outbound connections
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "survey-rds-sg"
  }
}

# DB Subnet Group for RDS
resource "aws_db_subnet_group" "survey_db_subnet_group" {
  name       = "survey-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  tags = {
    Name = "survey-db-subnet-group"
  }
}

# RDS PostgreSQL Instance
resource "aws_db_instance" "survey_db" {
  identifier             = "survey-db"
  engine                 = "postgres"
  engine_version         = "14"
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage
  db_name                = "survey_db"
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.survey_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  multi_az               = var.db_multi_az

  tags = {
    Name = "survey-db"
  }
}

# Application Load Balancer
resource "aws_lb" "survey_alb" {
  name               = "survey-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  tags = {
    Name = "survey-alb"
  }
}

# Target group for frontend
resource "aws_lb_target_group" "frontend_tg" {
  name        = "frontend-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.survey_vpc.id
  target_type = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200-399"
  }

  tags = {
    Name = "survey-frontend-tg"
  }
}

# Target group for API
resource "aws_lb_target_group" "api_tg" {
  name        = "api-tg"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.survey_vpc.id
  target_type = "ip"

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200-399"
  }

  tags = {
    Name = "survey-api-tg"
  }
}

# ALB Listener for HTTP
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.survey_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Please use the frontend application"
      status_code  = "200"
    }
  }
}

# Frontend path routing
resource "aws_lb_listener_rule" "frontend_rule" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

# API path routing
resource "aws_lb_listener_rule" "api_rule" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api_tg.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}

# S3 bucket for Docker images
resource "aws_s3_bucket" "docker_images" {
  bucket = "survey-docker-images-${random_string.bucket_suffix.result}"
  force_destroy = true

  tags = {
    Name = "survey-docker-images"
  }
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket_versioning" "docker_images_versioning" {
  bucket = aws_s3_bucket.docker_images.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "docker_images_public_access" {
  bucket = aws_s3_bucket.docker_images.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ECR Repositories for Docker images
resource "aws_ecr_repository" "frontend_repo" {
  name                 = "survey-frontend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "backend_repo" {
  name                 = "survey-backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "survey_cluster" {
  name = "survey-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "survey-cluster"
  }
}

resource "aws_ecs_cluster_capacity_providers" "survey_cluster_capacity" {
  cluster_name = aws_ecs_cluster.survey_cluster.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 1
  }
}

# IAM Roles and Policies for ECS Tasks
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_role" {
  name = "ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# Task Definitions
resource "aws_ecs_task_definition" "backend_task" {
  family                   = "survey-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.backend_task_cpu
  memory                   = var.backend_task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name         = "backend"
      image        = "${aws_ecr_repository.backend_repo.repository_url}:latest"
      essential    = true
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "DATABASE_URL"
          value = "postgresql+psycopg2://${var.db_username}:${var.db_password}@${aws_db_instance.survey_db.endpoint}/survey_db"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/survey-backend"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group"  = "true"
        }
      }
    }
  ])

  tags = {
    Name = "survey-backend-task"
  }
}

resource "aws_ecs_task_definition" "frontend_task" {
  family                   = "survey-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.frontend_task_cpu
  memory                   = var.frontend_task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name         = "frontend"
      image        = "${aws_ecr_repository.frontend_repo.repository_url}:latest"
      essential    = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "NEXT_PUBLIC_API_URL"
          value = "http://${aws_lb.survey_alb.dns_name}/api"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/survey-frontend"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group"  = "true"
        }
      }
    }
  ])

  tags = {
    Name = "survey-frontend-task"
  }
}

# ECS Services
resource "aws_ecs_service" "backend_service" {
  name            = "survey-backend-service"
  cluster         = aws_ecs_cluster.survey_cluster.id
  task_definition = aws_ecs_task_definition.backend_task.arn
  desired_count   = var.backend_service_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api_tg.arn
    container_name   = "backend"
    container_port   = 8000
  }

  depends_on = [
    aws_lb_listener.http_listener,
    aws_iam_role_policy_attachment.ecs_task_execution_role_policy,
    aws_db_instance.survey_db
  ]

  tags = {
    Name = "survey-backend-service"
  }
}

resource "aws_ecs_service" "frontend_service" {
  name            = "survey-frontend-service"
  cluster         = aws_ecs_cluster.survey_cluster.id
  task_definition = aws_ecs_task_definition.frontend_task.arn
  desired_count   = var.frontend_service_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend_tg.arn
    container_name   = "frontend"
    container_port   = 3000
  }

  depends_on = [
    aws_lb_listener.http_listener,
    aws_iam_role_policy_attachment.ecs_task_execution_role_policy
  ]

  tags = {
    Name = "survey-frontend-service"
  }
}