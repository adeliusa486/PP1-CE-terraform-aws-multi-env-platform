# ADR-001: State Management Architecture

## Status
Accepted

## Context
Standard Terraform requires duplicating backend configuration blocks across every environment (Dev, Staging, Prod), leading to code repetition and increased risk of state corruption due to configuration drift.

## Decision
We will use Terragrunt to wrap Terraform executions. Terragrunt will dynamically inject remote state configurations (S3 backend and DynamoDB locking) into the Terraform modules at runtime.

## Consequences
*   **Positive**: Completely DRY (Don't Repeat Yourself) backend configurations.
*   **Positive**: Enforced DynamoDB state locking across all environments.
*   **Negative**: Introduces a dependency on a third-party tool (Terragrunt) beyond standard HashiCorp Terraform.
