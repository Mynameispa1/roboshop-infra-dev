#Creating a target group
resource "aws_lb_target_group" "test" {
  name     = "${local.name}-${var.tags.Component}"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_ssm_parameter.vpc_id.value
  
  health_check {  #This is health check for the target group
    path = "/health"
    port = 8080
    healthy_threshold = 2
    unhealthy_threshold = 3
    timeout = 5
    interval = 10
    matcher = "200"  # has to be HTTP 200 or fails
  }
}