resource "aws_acm_certificate" "cert" {
  domain_name       = "*.fiffik.co.uk"
  validation_method = "DNS"


  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "tino" {
  name         = "fiffik.co.uk"
  private_zone = false
}

resource "aws_route53_record" "tinorudy" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.zone_id
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = var.aws_acm_cert_arn
  validation_record_fqdns = [for record in aws_route53_record.tinorudy : record.fqdn]
}

resource "aws_route53_record" "www" {
  zone_id = var.zone_id
  name    = "www"
  type    = "A"

  alias {
    name                   = var.aws_lb_dns_name
    zone_id                = var.aws_lb_zone_id
    evaluate_target_health = true
    
  }
}