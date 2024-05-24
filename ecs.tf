
resource "aws_ecr_repository" "my_ecr_repo" {
  name = var.app_name
}

resource "aws_ecs_cluster" "my_cluster" {
  name = "${var.app_name}-${terraform.workspace}"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/${var.app_name}-${terraform.workspace}"
  retention_in_days = 30
}

resource "aws_ecs_task_definition" "my_task" {
  family                   = "${var.app_name}-${terraform.workspace}"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "${var.app_name}-${terraform.workspace}",
      "image": "${var.ecr_image}",
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.ecs_log_group.name}",
          "awslogs-region": "${var.region}",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "portMappings": [
            {
              "name": "myapp-api-80-tcp",
              "containerPort": 80,
              "hostPort": 80,
              "protocol": "tcp"
            },
            {
              "name": "myapp-api-443-tcp",
              "containerPort": 443,
              "hostPort": 443,
              "protocol": "tcp"
            }
        ],
        "environment": [
            {
                "name": "PORT",
                "value": "${var.PORT}"
            },
            {
                "name": "PG_HOST",
                "value": "${var.PG_HOST}"
            },           
            {
                "name": "PG_PORT",
                "value": "${var.PG_PORT}"
            },           
            {
                "name": "POSTGRES_USER",
                "value": "${var.POSTGRES_USER}"
            },           
            {
                "name": "POSTGRES_PASSWORD",
                "value": "${var.POSTGRES_PASSWORD}"
            },           
            {
                "name": "POSTGRES_DB",
                "value": "${var.POSTGRES_DB}"
            }, 
            {
                "name": "JWT_SECRET",
                "value": "${var.JWT_SECRET}"
            }, 
            {
                "name": "JWT_EXPIRATION",
                "value": "${var.JWT_EXPIRATION}"
            }
            ],
      "memory": 512,
      "cpu": 256
    }
  ]
  
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskRole.arn

}
resource "aws_iam_role" "ecsTaskRole" {
  name               = "${var.app_name}-${terraform.workspace}TaskRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "MyEcsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_service" "my_service" {
  name            = "${var.app_name}-${terraform.workspace}-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = aws_ecs_task_definition.my_task.family
    container_port   = 80
  }
  network_configuration {
    subnets          = aws_subnet.private.*.id
    assign_public_ip = false
    security_groups  = ["${aws_security_group.service_security_group.id}"]

  }
}
resource "aws_security_group" "service_security_group" {
  name   = "${var.app_name}-${terraform.workspace}-service-sg"
  vpc_id = aws_vpc.default.id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_alb" "application_load_balancer" {
  name               = "${var.app_name}-${terraform.workspace}-LB"
  load_balancer_type = "application"
  subnets            = aws_subnet.public.*.id

  security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
}



resource "aws_security_group" "load_balancer_security_group" {
  name   = "${var.app_name}-${terraform.workspace}-LB-sg"
  vpc_id = aws_vpc.default.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "target_group" {
  name        = "${var.app_name}-${terraform.workspace}-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  #vpc_id      = aws_default_vpc.default_vpc.id
  vpc_id = aws_vpc.default.id
  health_check {
    matcher = "200,301,302"
    path    = "/"
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}


