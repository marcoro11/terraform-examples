app_name = "my-serverless-app"
stage    = "dev"

aws_region = "us-west-2"

enable_frontend = true
domain_name     = "app.yourdomain.com"  # Optional: your frontend domain

api_domain_name     = "api.yourdomain.com"  # Optional: custom API domain
api_certificate_arn = ""                   # Required if using custom API domain

cors_allowed_origins = [
  "https://app.yourdomain.com",
  "http://localhost:3000",  # for local development
  "http://localhost:8080"   # for local development
]

enable_waf = false  # Set to true for production

enable_dynamodb_backups = true
dynamodb_billing_mode   = "PAY_PER_REQUEST"  # or "PROVISIONED"

lambda_runtime     = "python3.11"
lambda_timeout     = 30
lambda_memory_size = 256

alarm_email_endpoint = "alerts@yourdomain.com"
log_retention_days   = 14

tags = {
  Owner       = "Platform"
  Project     = "ServerlessApp" 
  Environment = "Development"
  CostCenter  = "Engineering"
}