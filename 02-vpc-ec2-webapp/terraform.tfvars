project_name    = "my-webapp"
environment     = "dev"
key_pair_name   = "my-key-pair"  # Create this in AWS EC2 console first

db_password = "ChangeMe123!"  # Use a strong password

aws_region     = "us-west-2"
vpc_cidr       = "10.0.0.0/16"
allowed_cidr_blocks = ["0.0.0.0/0"]  # Restrict this in production

instance_type    = "t3.medium"
min_size         = 2
max_size         = 6
desired_capacity = 2

db_instance_class = "db.t3.micro"
db_name          = "webapp"
db_username      = "admin"

redis_node_type       = "cache.t3.micro"
redis_num_cache_nodes = 1

sns_email_endpoint = "your-email@example.com"

enable_nat_gateway = true
enable_flow_logs   = true
enable_vpn_gateway = false

tags = {
  Owner      = "YourName"
  Project    = "WebApp"
  CostCenter = "Development"
}