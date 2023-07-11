variable "domain_name" {
  type        = string
  description = "Main website"
  default     = "mywebsite.com" # DOMAIN #
}

resource "aws_route53_zone" "primary" {
  name = var.domain_name
}

data "aws_route53_zone" "hosted_zone" {
	depends_on = [aws_route53_zone.primary]
  name = var.domain_name
}

resource "aws_route53_record" "websiteurl" {
  name    = var.domain_name
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "adminurl" {
	zone_id = aws_route53_zone.primary.zone_id
  name    = "admin.mywebsite.com" # SUBDOMAIN A #
  type    = "A"
  ttl     = 300
  records = ["1.11.11.111"] # IP A #
}

resource "aws_route53_record" "testfrontend" {
	zone_id = aws_route53_zone.primary.zone_id
  name    = "test.mywebsite.com" # SUBDOMAIN B #
  type    = "A"
  ttl     = 300
  records = ["1.11.11.111"] # IP B #
}

resource "aws_s3_bucket" "b" {
  bucket = "mywebsite-web" # PUBLIC BUCKET #

  tags = {
    Name = "Website"
  }
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.b.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [aws_s3_bucket_ownership_controls.example]

  bucket = aws_s3_bucket.b.id
  acl    = "public-read"
}

resource "aws_s3_bucket_public_access_block" "b" {
  bucket = aws_s3_bucket.b.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "allow_public_access" {
  bucket = aws_s3_bucket.b.id
  policy = data.aws_iam_policy_document.allow_public_access.json
}

data "aws_iam_policy_document" "allow_public_access" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      aws_s3_bucket.b.arn,
      "${aws_s3_bucket.b.arn}/*",
    ]
  }
}

locals {
  s3_origin_id = "myS3Origin"
}

resource "aws_cloudfront_origin_access_control" "default" {
  name                              = "default"
  description                       = "Default Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_origin_access_identity" "default" {
  comment = "Some comment"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.b.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
    origin_id                = local.s3_origin_id

    #s3_origin_config {
    #  origin_access_identity = aws_cloudfront_origin_access_identity.default.cloudfront_access_identity_path
    #}

#		custom_origin_config {
#	    http_port              = 80
#	    https_port             = 443
#	    origin_protocol_policy = "http-only"
#	    origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
#	  }
  }

  comment             = "mywebsite.com" # DOMAIN #
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = ["mywebsite.com"] # DOMAIN #

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  tags = {
    Environment = "production"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = "arn:aws:acm:us-east-1:207142590424:certificate/aaaaaaaa-1111-4444-4444-555555555555" # SSL CERTIFICATE #
    ssl_support_method = "sni-only"
  }
}