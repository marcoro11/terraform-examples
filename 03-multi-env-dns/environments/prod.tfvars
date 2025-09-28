root_domain = "yourdomain.com"  # Replace with your actual domain

aws_region = "us-west-2"

vpc_cidr = "10.2.0.0/16"  # Different CIDR for production

enable_waf    = true   # Enable WAF for production
enable_shield = true   # Enable Shield Advanced for DDoS protection

notification_email = "prod-alerts@yourdomain.com"

custom_instance_type      = "t3.large"    # Larger instances for prod
custom_min_size          = 3              # Higher minimum
custom_max_size          = 20             # Higher maximum
custom_db_instance_class = "db.t3.large"  # Larger RDS instance

tags = {
  Owner       = "Platform"
  Project     = "WebApp"
  Environment = "Production" 
  CostCenter  = "Infrastructure"
  Backup      = "Required"
  Monitoring  = "Critical"
}