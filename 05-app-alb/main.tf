#1) Creating app load balancer

resource "aws_lb" "app_alb" {
  name               = "${local.name}-${var.tags.Component}"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [data.aws_ssm_parameter.app_alb_sg_id.value]
  subnets            = split(",", data.aws_ssm_parameter.private_subnet_ids.value) #we need to provide two subnets while creating Load balancer at app level
    
  #enable_deletion_protection = true

  tags = merge(
    var.common_tags,
    var.tags
  )
}

#2) Listner and rules for the load balancer
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "This response from app LB"
      status_code  = "200"
    }
  }
}


#3) We are creating DNS record because the default dns will keep change whenever we delete and create the resource  // *.app-dev.pavankumarmuvva.online //
module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"

  zone_name = var.zone_name

  records = [
    {
      name    = "*.app-${var.environment}"  #*.app-dev and pavankumarmuvva.online will take automatically
      type    = "A"
      alias   = {
        name    = aws_lb.app_alb.dns_name
        zone_id = aws_lb.app_alb.zone_id
      }
    }
  ]

}

