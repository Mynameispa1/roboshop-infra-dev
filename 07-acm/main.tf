#1) Hear we are creating the certificate using acm (amazon certificate manager)
#2) Cretaing record
#3) Validation certificate

#acm certification creation
resource "aws_acm_certificate" "pavankumarmuvva" {
  domain_name       = "*.pavankumarmuvva.online"
  validation_method = "DNS"

  tags = merge (
  var.tags,
  var.common_tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

#record creation
resource "aws_route53_record" "pavankumarmuvva" {
  for_each = {
    for dvo in aws_acm_certificate.pavankumarmuvva.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 1
  type            = each.value.type
  zone_id         = data.aws_route53_zone.pavankumarmuvva.zone_id
}

# aws acm certificate validation 
resource "aws_acm_certificate_validation" "pavankumarmuvva" {
  certificate_arn         = aws_acm_certificate.pavankumarmuvva.arn
  validation_record_fqdns = [for record in aws_route53_record.pavankumarmuvva : record.fqdn]
}