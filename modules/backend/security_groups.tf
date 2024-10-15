resource "aws_security_group" "test_airflow" {
  name        = "${var.app_name}-${var.environment}-Airflow-sg"
  description = "this is testing sg for air flow dags"
  vpc_id      = "vpc-0e78369019b380561"

  # Ingress rule (allow traffic from the same security group)
  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    self             = true
  }

  # Egress rule (allow all outbound traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}




resource "aws_security_group" "lb_sg" {
  name        = "${var.app_name}-${var.environment}-Alb-sg"
  description = "Security group for the load balancer"
  vpc_id      = "vpc-0e78369019b380561"

  # Ingress rule (allow HTTPS traffic on port 443 from anywhere)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rule (allow all outbound traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}


variable "ecs_ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["192.168.0.0/16"] },
    { from_port = 5432, to_port = 5432, protocol = "tcp", cidr_blocks = ["192.168.0.0/16"] },
    { from_port = 8080, to_port = 8080, protocol = "tcp", cidr_blocks = ["192.168.0.0/16"] },
    { from_port = 2024, to_port = 2024, protocol = "tcp", cidr_blocks = ["192.168.0.0/16"] },
    { from_port = 6379, to_port = 6379, protocol = "tcp", cidr_blocks = ["192.168.0.0/16"] },
    { from_port = 5005, to_port = 5005, protocol = "tcp", cidr_blocks = ["192.168.0.0/16"] },
    { from_port = 49152, to_port = 49152, protocol = "tcp", cidr_blocks = ["192.168.0.0/16"] },
    { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["192.168.0.0/16", "136.226.104.0/23", "136.226.100.0/23", "165.225.216.0/23", "165.225.32.0/23", "165.225.36.0/23", "136.226.102.0/23"] },
    { from_port = 5001, to_port = 5001, protocol = "tcp", cidr_blocks = ["192.168.0.0/16"] }
  ]
}

resource "aws_security_group" "ecs_sg" {
  name        = "${var.app_name}-${var.environment}-Ecs-sg"
  description = "Security group for the ecs"
  vpc_id      = "vpc-0e78369019b380561"

  dynamic "ingress" {
    for_each = var.ecs_ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}