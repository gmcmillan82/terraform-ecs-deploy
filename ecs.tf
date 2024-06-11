resource "aws_ecs_cluster" "ecs_cluster" {
  name = "demo-cluster"
}

resource "aws_ecs_task_definition" "ecs_task" {
  family = "demo-app-td"

  cpu    = "256"
  memory = "512"

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = data.aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "demo-app"
      image     = "${var.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/demo-app:production" # GHA will create a :production tag on merge to master
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_lb" "nlb" {
  name               = "demo-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = data.aws_subnets.default.ids
}

resource "aws_lb_target_group" "nlb_tg" {
  name        = "demo-app-tg"
  port        = 5000
  protocol    = "TCP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"
}

resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_tg.arn
  }
}

resource "aws_ecs_service" "ecs_service" {
  name            = "fargate-service"
  cluster         = aws_ecs_cluster.ecs_cluster.arn
  task_definition = aws_ecs_task_definition.ecs_task.arn
  launch_type     = "FARGATE"
  desired_count   = 2

  load_balancer {
    target_group_arn = aws_lb_target_group.nlb_tg.arn
    container_name   = "demo-app"
    container_port   = 5000
  }

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}

resource "aws_security_group" "ecs_sg" {
  name   = "ecs-sg"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
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


