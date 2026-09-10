resource "aws_lb" "gateway" {
  name               = "${var.gateway_name}-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.private_subnet_ids
  security_groups    = [var.gateway_nlb_sg_id]

  tags = {
    Name = "${var.project_name}-gateway"
  }
}

resource "aws_lb_target_group" "gateway" {
  name        = "${var.gateway_name}-tg"
  port        = var.gateway_node_port
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    protocol = "TCP"
    port     = var.gateway_node_port
  }
}

resource "aws_lb_listener" "gateway" {
  load_balancer_arn = aws_lb.gateway.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gateway.arn
  }
}