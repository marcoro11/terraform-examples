resource "aws_s3_bucket" "website" {
  count = var.enable_website_hosting ? 1 : 0

  bucket = "${var.app_name}-website-${var.stage}"

  tags = merge(var.tags, {
    Name = "${var.app_name}-website-${var.stage}"
    Type = "Website"
  })
}

resource "aws_s3_bucket_public_access_block" "website" {
  count = var.enable_website_hosting ? 1 : 0

  bucket = aws_s3_bucket.website[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "website" {
  count = var.enable_website_hosting ? 1 : 0

  bucket = aws_s3_bucket.website[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "website" {
  count = var.enable_website_hosting ? 1 : 0

  bucket = aws_s3_bucket.website[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket" "files" {
  bucket = "${var.app_name}-files-${var.stage}"

  tags = merge(var.tags, {
    Name = "${var.app_name}-files-${var.stage}"
    Type = "Files"
  })
}

resource "aws_s3_bucket_public_access_block" "files" {
  bucket = aws_s3_bucket.files.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "files" {
  bucket = aws_s3_bucket.files.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "files" {
  bucket = aws_s3_bucket.files.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_cors_configuration" "files" {
  bucket = aws_s3_bucket.files.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
    allowed_origins = var.cors_allowed_origins
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_cloudfront_origin_access_identity" "website" {
  count = var.enable_website_hosting ? 1 : 0

  comment = "OAI for ${var.app_name} website"
}

resource "aws_cloudfront_distribution" "website" {
  count = var.enable_website_hosting ? 1 : 0

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.app_name} website distribution"
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  origin {
    domain_name = aws_s3_bucket.website[0].bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.website[0].bucket}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.website[0].cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.website[0].bucket}"

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

    # CloudFront Functions for SPA routing (optional)
    dynamic "function_association" {
      for_each = var.enable_spa_routing ? [1] : []
      content {
        event_type   = "viewer-request"
        function_arn = aws_cloudfront_function.spa_routing[0].function_arn
      }
    }
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  viewer_certificate {
    cloudfront_default_certificate = var.domain_name == "" ? true : false
    acm_certificate_arn            = var.domain_name != "" ? var.acm_certificate_arn : null
    ssl_support_method             = var.domain_name != "" ? "sni-only" : null
    minimum_protocol_version       = var.domain_name != "" ? "TLSv1.2_2021" : null
  }

  aliases = var.domain_name != "" ? [var.domain_name] : []

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = merge(var.tags, {
    Name = "${var.app_name}-website-${var.stage}"
  })
}

resource "aws_cloudfront_function" "spa_routing" {
  count = var.enable_website_hosting && var.enable_spa_routing ? 1 : 0

  name    = "${var.app_name}-spa-routing-${var.stage}"
  runtime = "cloudfront-js-1.0"
  comment = "SPA routing function for ${var.app_name}"
  publish = true
  code    = <<-EOF
function handler(event) {
    var request = event.request;
    var uri = request.uri;

    // Check if the URI is a file extension
    if (uri.includes('.')) {
        return request;
    }

    // For all other requests, serve index.html
    request.uri = '/index.html';
    return request;
}
EOF
}

resource "aws_s3_bucket_policy" "website" {
  count = var.enable_website_hosting ? 1 : 0

  bucket = aws_s3_bucket.website[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontAccess"
        Effect    = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.website[0].iam_arn
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.website[0].arn}/*"
      }
    ]
  })
}

resource "aws_route53_record" "website" {
  count = var.enable_website_hosting && var.domain_name != "" ? 1 : 0

  zone_id = var.route53_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website[0].domain_name
    zone_id               = aws_cloudfront_distribution.website[0].hosted_zone_id
    evaluate_target_health = false
  }
}