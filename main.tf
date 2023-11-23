resource "aws_s3_bucket" "mybucket" {
  bucket = var.root_domain_name
}

resource "aws_s3_bucket" "wwwbucket" {
  bucket = var.www_domain_name
}

resource "aws_s3_bucket_ownership_controls" "wwwowner" {
  bucket = aws_s3_bucket.wwwbucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_website_configuration" "wwwwebsite" {
    bucket = aws_s3_bucket.wwwbucket.id
    redirect_all_requests_to {
      host_name = var.root_domain_name
    }
    depends_on = [ aws_s3_bucket_ownership_controls.wwwowner ]
}


resource "aws_cloudfront_distribution" "wwwdistribution" {
  enabled         = true
  is_ipv6_enabled = true

  origin {
    domain_name = aws_s3_bucket_website_configuration.wwwwebsite.website_endpoint
    origin_id   = aws_s3_bucket.wwwbucket.bucket_regional_domain_name

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = 30
      origin_ssl_protocols = [
        "TLSv1.2",
      ]
    }
  }

  aliases = [var.www_domain_name]

  viewer_certificate {
        acm_certificate_arn      = aws_acm_certificate_validation.cert_validation.certificate_arn
        ssl_support_method       = "sni-only"
        minimum_protocol_version = "TLSv1.1_2016"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  default_cache_behavior {
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.wwwbucket.bucket_regional_domain_name
  }
}


resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.my_hosted_zone.zone_id

  name = var.www_domain_name
  type = "A"

  alias {
    name                   = aws_cloudfront_distribution.wwwdistribution.domain_name
    zone_id                = aws_cloudfront_distribution.wwwdistribution.hosted_zone_id
    evaluate_target_health = false
  }

  depends_on = [ aws_route53_zone.my_hosted_zone ]
}

resource "aws_s3_bucket_ownership_controls" "owner" {
  bucket = aws_s3_bucket.mybucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "public" {
    bucket = aws_s3_bucket.mybucket.id

    block_public_acls = false
    block_public_policy = false
    ignore_public_acls = false
    restrict_public_buckets = false
  
}

resource "aws_s3_bucket_acl" "acl" {
    depends_on = [ 
        aws_s3_bucket_ownership_controls.owner, 
        aws_s3_bucket_public_access_block.public,
    ]

    bucket = aws_s3_bucket.mybucket.id
    acl = "public-read"
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.mybucket.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "PublicReadGetObject",
          "Effect" : "Allow",
          "Principal" : "*",
          "Action" : "s3:GetObject",
          "Resource" : "arn:aws:s3:::${aws_s3_bucket.mybucket.id}/*"
        }
      ]
    }
  )
}

resource "aws_s3_object" "bootstrap_files" {
  for_each = fileset(local.s3_filepath, "**")
  bucket = aws_s3_bucket.mybucket.id
  key    = each.key
  source = "${local.s3_filepath}/${each.value}"
  content_type = lookup(local.content_types, regex("\\.[^.]+$", each.value), null)
  etag   = filemd5("${local.s3_filepath}/${each.value}")
  acl = "public-read"

  depends_on = [aws_s3_bucket_acl.acl]
}

resource "aws_s3_bucket_website_configuration" "website" {
    bucket = aws_s3_bucket.mybucket.id
    index_document {
      suffix = "index.html"
    }
    error_document {
      key = "index.html"
    }
    depends_on = [ aws_s3_bucket_acl.acl ]
}

# SSL Certificate
resource "aws_acm_certificate" "ssl_certificate" {
  provider                  = aws.acm_provider
  domain_name               = var.root_domain_name
  subject_alternative_names = ["*.${var.root_domain_name}"]
  #validation_method         = "EMAIL"
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "main" {
    for_each = {
        for dvo in aws_acm_certificate.ssl_certificate.domain_validation_options : dvo.domain_name => {
            name = dvo.resource_record_name
            record = dvo.resource_record_value
            type = dvo.resource_record_type
        }
    }
    allow_overwrite = true
    name = each.value.name
    records = [each.value.record]
    ttl = 60
    type = each.value.type
    zone_id = aws_route53_zone.my_hosted_zone.zone_id
}

# Uncomment the validation_record_fqdns line if you do DNS validation instead of Email.
resource "aws_acm_certificate_validation" "cert_validation" {
  provider        = aws.acm_provider
  certificate_arn = aws_acm_certificate.ssl_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.main : record.fqdn]
}

resource "aws_cloudfront_distribution" "distribution" {
  enabled         = true
  is_ipv6_enabled = true

  origin {
    domain_name = aws_s3_bucket_website_configuration.website.website_endpoint
    origin_id   = aws_s3_bucket.mybucket.bucket_regional_domain_name

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = 30
      origin_ssl_protocols = [
        "TLSv1.2",
      ]
    }
  }

  viewer_certificate {
        acm_certificate_arn      = aws_acm_certificate_validation.cert_validation.certificate_arn
        ssl_support_method       = "sni-only"
        minimum_protocol_version = "TLSv1.1_2016"
  }

  aliases = [var.root_domain_name]

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  default_cache_behavior {
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.mybucket.bucket_regional_domain_name
  }
}

import {
  to = aws_route53_zone.my_hosted_zone
  id = var.my_zone_id
}

resource "aws_route53_zone" "my_hosted_zone" {
  name = var.root_domain_name
}


resource "aws_route53_record" "exampleDomain-a" {
  zone_id = aws_route53_zone.my_hosted_zone.zone_id
  name    = var.root_domain_name
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.distribution.domain_name
    zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
    evaluate_target_health = false
  }
}