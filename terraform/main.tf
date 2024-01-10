provider "aws" {
  region = "us-east-1"
}

resource "aws_ecs_cluster" "my_cluster" {
  name = "my-cluster"
}

resource "aws_launch_configuration" "my_launch_config" {
  name = "my-launch-config"
  image_id = "ami-xxxxxxxxxxxxxxxxx"  # Substitua pelo AMI desejado
  instance_type = "t2.micro"
  user_data = <<-EOF
              #!/bin/bash
              echo ECS_CLUSTER=${aws_ecs_cluster.my_cluster.name} >> /etc/ecs/ecs.config
              EOF
}

resource "aws_autoscaling_group" "my_asg" {
  desired_capacity     = 2
  max_size             = 5
  min_size             = 1
  health_check_type    = "EC2"
  force_delete         = true

  vpc_zone_identifier  = ["subnet-xxxxxxxxxxxxxxx", "subnet-yyyyyyyyyyyyyyy"]  # Substitua pelos IDs das sub-redes em diferentes regiões

  launch_configuration = aws_launch_configuration.my_launch_config.name

  tag {
    key                 = "Name"
    value               = "my-instance"
    propagate_at_launch = true
  }
}

resource "aws_ecs_task_definition" "my_task" {
  family                   = "my-task"
  container_definitions   = <<DEF
  [
    {
      "name": "my-container",
      "image": "your-docker-image:latest",
      "memoryReservation": 256,
      "essential": true,
      "cpu": 256
    }
    # Adicione mais definições de contêineres conforme necessário
  ]
  DEF
}

resource "aws_ecs_service" "my_service" {
  name            = "my-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task.arn
  launch_type     = "EC2"

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  network_configuration {
    subnets = ["subnet-xxxxxxxxxxxxxxx", "subnet-yyyyyyyyyyyyyyy"]  # Substitua pelos IDs das sub-redes em diferentes regiões
    security_groups = ["sg-xxxxxxxxxxxxxxxxx"]  # Substitua pelo ID do grupo de segurança
  }
}
