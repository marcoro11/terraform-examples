resource "aws_cloudfront_origin_access_identity" "main" {
  comment = "OAI for ${var.domain_name}"
}

resource "aws_cloudfront_distribution" "main" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.environment} distribution for ${var.domain_name}"
  default_root_object = "index.html"
  price_class         = var.price_class

  origin {
    domain_name = var.s3_bucket_domain_name
    origin_id   = "S3-${var.domain_name}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.main.cloudfront_access_identity_path
    }
  }

  dynamic "origin" {
    for_each = var.alb_domain_name != "" ? [1] : []
    content {
      domain_name = var.alb_domain_name
      origin_id   = "ALB-${var.domain_name}"

      custom_origin_config {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.domain_name}"

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

    dynamic "function_association" {
      for_each = var.enable_edge_functions ? [1] : []
      content {
        event_type   = "viewer-request"
        function_arn = aws_cloudfront_function.viewer_request[0].function_arn
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.alb_domain_name != "" ? [1] : []
    content {
      path_pattern     = "/api/*"
      allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods   = ["GET", "HEAD"]
      target_origin_id = "ALB-${var.domain_name}"

      forwarded_values {
        query_string = true
        headers      = ["*"]
        cookies {
          forward = "all"
        }
      }

      viewer_protocol_policy = "redirect-to-https"
      min_ttl                = 0
      default_ttl            = 0
      max_ttl                = 0
    }
  }

  custom_error_response {
    error_code         = 404
    response_code      = 404
    response_page_path = "/404.html"
  }

  custom_error_response {
    error_code         = 500
    response_code      = 500
    response_page_path = "/500.html"
  }

  viewer_certificate {
    acm_certificate_arn      = var.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  web_acl_id = var.waf_acl_arn != "" ? var.waf_acl_arn : null

  tags = merge(var.tags, {
    Name = "${var.environment}-cdn-${var.domain_name}"
  })
}

resource "aws_cloudfront_function" "viewer_request" {
  count = var.enable_edge_functions ? 1 : 0

  name    = "${var.environment}-viewer-request"
  runtime = "cloudfront-js-1.0"
  comment = "Viewer request function for ${var.domain_name}"
  publish = true
  code    = <<-EOF
function handler(event) {
    var request = event.request;
    var uri = request.uri;

    // Add index.html to directory requests
    if (uri.endsWith('/')) {
        request.uri += 'index.html';
    }
    // Add .html extension to requests without extension
    else if (!uri.includes('.')) {
        request.uri += '/index.html';
    }

    return request;
}
EOF
}