# AWS Multi-Environment Infrastructure Platform

[![Infrastructure Validation](https://github.com/adeliusa486/terraform-aws-multi-env-platform/actions/workflows/validation.yml/badge.svg)](https://github.com/adeliusa486/terraform-aws-multi-env-platform/actions/workflows/validation.yml)

This repository contains the Infrastructure as Code (IaC) for a modular, production-ready AWS environment using Terraform and Terragrunt. 

The infrastructure is treated strictly as application code: version-controlled, heavily modularized, and reproducible across isolated environments.

## Proof of Deployment

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

## Repository Structure

| Directory | Purpose |
|---|---|
| /environments/dev | Development environment configuration (single NAT, minimal redundancy). |
| /environments/prod | Production environment configuration (Multi-AZ, high availability). |
| /modules/ | Reusable Terraform modules for Networking, Compute, Database, Containers, Serverless, and Frontend. |
| /.github/workflows | CI/CD pipelines for automated Terraform formatting and validation. |

## Architectural Highlights

### 1. Network Isolation and Cost Control
The network topology uses a public/private subnet split across multiple Availability Zones. The 
etworking module accepts a boolean variable to enforce a single NAT Gateway in the Development environment for cost optimization, while Production utilizes redundant gateways across all zones.

### 2. Zero-Trust Compute Tier
The compute layer runs entirely on AWS Fargate. To enforce a Zero-Trust security model, the ECS Security Group explicitly drops all incoming internet traffic, strictly accepting packets originating from the Application Load Balancer.

### 3. Dynamic Secrets Management
Database passwords are never hardcoded or committed to variable files. Terraform uses a cryptographic provider to generate credentials in memory during provisioning, injecting them directly into AWS Secrets Manager.

### 4. Secured Edge Delivery
Static frontend assets are hosted in Amazon S3 with public internet access strictly blocked. Global distribution is handled by Amazon CloudFront, utilizing Origin Access Control (OAC) to cryptographically sign requests to the bucket.

## Deployment Guide

To deploy this infrastructure, ensure the AWS CLI, Terraform, and Terragrunt are installed and authenticated.

### 1. Navigate to the Target Environment
`ash
cd environments/dev
`

### 2. Initialize the Remote State Backend
`ash
terragrunt init
`

### 3. Review the Execution Plan
`ash
terragrunt plan
`

### 4. Provision the Infrastructure
`ash
terragrunt apply
`

Always remember to run 	erragrunt destroy when you are finished testing to prevent unexpected AWS billing charges.
