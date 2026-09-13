provider "aws" {
  region = "us-east-1"
}

# Step 3: Build the Network
module "networking" {
  source = "../../modules/networking"

  environment        = "dev"
  vpc_cidr           = "10.0.0.0/16"
  azs                = ["us-east-1a", "us-east-1b"]
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets    = ["10.0.11.0/24", "10.0.12.0/24"]
  single_nat_gateway = true 
}

# Step 4: Build the Security Boundaries
module "iam" {
  source      = "../../modules/iam"
  environment = "dev"
}

# Step 5A: Build the Compute Layer (ALB)
module "compute" {
  source = "../../modules/compute"
  
  environment       = "dev"
  vpc_id            = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids
}

# Step 5B: Build the ECS Containers Layer
module "containers" {
  source = "../../modules/containers"
  
  environment           = "dev"
  vpc_id                = module.networking.vpc_id
  private_subnet_ids    = module.networking.private_subnet_ids
  target_group_arn      = module.compute.target_group_arn
  alb_security_group_id = module.compute.alb_security_group_id
}

# Step 6: Build the Database Layer
module "database" {
  source = "../../modules/database"
  
  environment        = "dev"
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  multi_az           = false
}

# Step 7: Build the Serverless API Layer
module "serverless" {
  source      = "../../modules/serverless"
  environment = "dev"
}

# Step 8: Build the Static CDN Layer
module "frontend" {
  source      = "../../modules/frontend"
  environment = "dev"
}