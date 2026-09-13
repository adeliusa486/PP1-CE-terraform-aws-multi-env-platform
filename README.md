# AWS Multi-Environment Infrastructure Platform

[![Infrastructure Validation](https://github.com/adeliusa486/terraform-aws-multi-env-platform/actions/workflows/validation.yml/badge.svg)](https://github.com/adeliusa486/terraform-aws-multi-env-platform/actions/workflows/validation.yml)

Welcome to my Infrastructure as Code (IaC) platform. I built this repository to demonstrate how to deploy a modular, production-ready AWS environment from scratch using Terraform and Terragrunt. 

The primary goal of this project was to move away from manually provisioning resources in the AWS Console. Instead, the entire infrastructure is treated exactly like application code: version-controlled, peer-reviewed, heavily modularized, and 100% reproducible. 

## Proof of Deployment

To verify that this code executes successfully in a real AWS environment, I have included captures of the deployed resources. I used an HTML grid layout below to keep the documentation clean and concise.

<table>
  <tr>
    <td align="center">
      <img src="docs/images/vpc-config.png" alt="VPC Configuration" width="100%"><br>
      <b>Isolated Network Topology (VPC & Subnets)</b>
    </td>
    <td align="center">
      <img src="docs/images/target-group.png" alt="ALB Target Group" width="100%"><br>
      <b>Application Load Balancer Routing</b>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="docs/images/s3-state.png" alt="S3 Remote State" width="100%"><br>
      <b>Encrypted S3 Remote State Bucket</b>
    </td>
    <td align="center">
      <img src="docs/images/terraform-apply.png" alt="Terraform Apply" width="100%"><br>
      <b>Automated Terraform Provisioning</b>
    </td>
  </tr>
</table>

## How the Repository is Structured

I designed the directory tree to enforce a strict separation between the "logic" (the modules) and the "data" (the environments). This ensures we can spin up a new environment just by passing a different variable file, rather than copying and pasting thousands of lines of HCL.

`	ext
terraform-aws-multi-env-platform/
+-- environments/
¦   +-- dev/                  # Development variables and module wiring
¦   +-- prod/                 # Production variables (High Availability)
¦   +-- terragrunt.hcl        # Root configuration for S3/DynamoDB state locking
+-- modules/
¦   +-- networking/           # VPC, Public/Private Subnets, dynamic NAT Gateways
¦   +-- compute/              # Application Load Balancer and Target Groups
¦   +-- containers/           # ECS Fargate Cluster, Task Definitions, and Services
¦   +-- database/             # RDS MySQL instances and Secrets Manager integration
¦   +-- serverless/           # API Gateway, Lambda functions, and DynamoDB tables
¦   +-- frontend/             # S3 buckets and CloudFront CDN with OAC
+-- .github/workflows/        # CI/CD pipelines for automated Terraform validation
+-- Makefile                  # Command shortcuts for local deployment
`

## Architectural Highlights

When designing this platform, I focused heavily on security, high availability, and cost optimization. 

### 1. Network Isolation and Cost Control
The network topology uses a classic public/private subnet split across multiple Availability Zones. Because NAT Gateways charge an hourly fee, the 
etworking module accepts a single_nat_gateway boolean variable. This allows the Dev environment to route all traffic through a single NAT to save money, while the Prod environment can deploy a NAT in every AZ for strict redundancy.

### 2. Zero-Trust Compute Tier
The compute layer runs entirely on serverless AWS Fargate containers. To enforce a Zero-Trust security model, the ECS Security Group is configured to drop all incoming internet traffic. The only packets allowed to reach the containers are those originating explicitly from the Application Load Balancer's Security Group.

### 3. Dynamic Secrets Management
Database passwords are a common attack vector. In this architecture, passwords are never hardcoded, typed into a terminal, or committed to a .tfvars file. Instead, Terraform uses a cryptographic provider to generate a random 16-character string in memory during provisioning, which is then injected directly into AWS Secrets Manager and passed to the RDS instance. 

### 4. Secured Edge Delivery
Static frontend assets are hosted in Amazon S3, but the bucket completely blocks public internet access. Global distribution is handled by Amazon CloudFront, which uses an Origin Access Control (OAC) policy to cryptographically sign requests to the bucket. This prevents users from bypassing the CDN.

## Deployment Guide

If you want to spin this infrastructure up in your own AWS account, you will need the AWS CLI, Terraform, and Terragrunt installed.

1. Authenticate your terminal with your AWS IAM credentials.
2. Navigate to the desired environment:
   `ash
   cd environments/dev
   `
3. Initialize the remote state backend (S3 and DynamoDB):
   `ash
   terragrunt init
   `
4. Review the infrastructure plan:
   `ash
   terragrunt plan
   `
5. Provision the resources:
   `ash
   terragrunt apply
   `

Always remember to run 	erragrunt destroy when you are finished testing to prevent unexpected AWS billing charges.
