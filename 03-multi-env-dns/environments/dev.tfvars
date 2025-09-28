root_domain = "yourdomain.com"  # Replace with your actual domain

aws_region = "us-west-2"

vpc_cidr = "10.0.0.0/16"

enable_waf    = false
enable_shield = false

notification_email = "dev-alerts@yourdomain.com"

# custom_instance_type = "t3.nano"  # Even smaller for dev
# custom_min_size = 1
# custom_max_size = 2

tags = {
  Owner       = "DevTeam"
  Project     = "WebApp"
  Environment = "Development"
  CostCenter  = "Engineering"
}