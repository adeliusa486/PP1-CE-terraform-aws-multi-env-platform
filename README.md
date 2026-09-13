# Enterprise AWS Infrastructure Platform

A deterministic, multi-environment infrastructure provisioning platform built with Terraform and Terragrunt. This repository defines the strict network boundaries, containerized compute, and relational data storage required to run a highly available web application.

## System Architecture

`mermaid
graph TD
    Client[Client] --> CF[CloudFront CDN]
    Client --> ALB[Application Load Balancer]
    Client --> API[API Gateway]

    subgraph AWS VPC
        CF --> OAC[Origin Access Control]
        OAC --> S3[S3 Static Assets]

        ALB --> ECS[ECS Fargate Cluster]
        ECS --> RDS[(RDS MySQL)]

        API --> L[AWS Lambda]
        L --> DDB[(DynamoDB)]
    end
`

## Core Engineering Principles

*   **Environment Isolation**: Development and Production environments are physically isolated at the VPC level.
*   **DRY Configuration**: Terragrunt dynamically injects remote state configurations, eliminating duplicated backend blocks across environments.
*   **State Locking**: Concurrent infrastructure mutations are prevented via DynamoDB state locking.
*   **Secret Management**: Database credentials are cryptographically generated in memory and injected directly into AWS Secrets Manager. Passwords are never written to disk or hardcoded in .tfvars.
*   **Zero-Trust Networking**: The ECS Fargate compute tier explicitly drops all ingress traffic except packets originating directly from the Application Load Balancer security group.
*   **Edge Security**: S3 bucket public access is strictly blocked. Assets are exclusively served through CloudFront via Origin Access Control (OAC) signatures.

## Proof of Implementation

### Infrastructure Provisioning
![Terraform Execution Plan](docs/images/terraform-plan.png)

### Network Topology
![AWS VPC Configuration](docs/images/vpc-config.png)

### Compute Routing
![ALB Target Group](docs/images/target-group.png)

### Data Tier Security
![AWS Secrets Manager](docs/images/secrets-manager.png)

## Modules Directory

| Module | Description | Stateful |
|---|---|---|
| 
etworking | Multi-AZ VPC, Subnets, IGW, and dynamic NAT Gateways | No |
| compute | Application Load Balancer, Listeners, and Target Groups | No |
| containers | ECS Cluster, Fargate Task Definitions, and Services | No |
| database | RDS Multi-AZ instances, Subnet Groups, and Secrets | Yes |
| rontend | CloudFront Distributions, OAC, and S3 Buckets | Yes |
| serverless | API Gateway, Lambda execution roles, and DynamoDB | Yes |

## Deployment Operations

### Initialization
`ash
cd environments/dev
terragrunt init
`

### Validation
`ash
terragrunt plan
`

### Execution
`ash
terragrunt apply
`

## Known Limitations

*   **Application Auto Scaling**: The ECS service currently relies on a static desired_count. CloudWatch metric alarms for dynamic CPU/Memory scaling are not yet implemented.
*   **Disaster Recovery**: RDS automated backups are enabled with a 7-day retention period, but cross-region replication is excluded from the current baseline.
