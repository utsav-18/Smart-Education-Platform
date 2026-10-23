locals {
  target_group_prefix = substr("${var.name}-${substr(sha1(var.name), 0, 6)}", 0, 22)
}

resource "aws_lb" "this" {
  name               = var.name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.subnet_ids

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_lb_target_group" "frontend" {
  name        = "${local.target_group_prefix}-fe"
  port        = var.frontend_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/"
    matcher             = "200-399"
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = var.tags
}

resource "aws_lb_target_group" "backend" {
  name        = "${local.target_group_prefix}-be"
  port        = var.backend_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/readyz"
    matcher             = "200"
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = var.tags
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

resource "aws_lb_listener_rule" "api" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.backend.arn
      }
    }
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}

resource "aws_lb_listener_rule" "health" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 110

  action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.backend.arn
      }
    }
  }

  condition {
    path_pattern {
      values = ["/health"]
    }
  }
}

resource "aws_lb_listener_rule" "readyz" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 120

  action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.backend.arn
      }
    }
  }

  condition {
    path_pattern {
      values = ["/readyz"]
    }
  }
}
