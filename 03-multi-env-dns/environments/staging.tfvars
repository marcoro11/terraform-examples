root_domain = "yourdomain.com"  # Replace with your actual domain

aws_region = "us-west-2"

vpc_cidr = "10.1.0.0/16"  # Different CIDR for staging

enable_waf    = true   # Enable WAF for staging testing
enable_shield = false

notification_email = "staging-alerts@yourdomain.com"

# custom_instance_type = "t3.small"
# custom_min_size = 2
# custom_max_size = 4

tags = {
  Owner       = "QATeam"
  Project     = "WebApp"
  Environment = "Staging"
  CostCenter  = "Engineering"
}