# Security Policy

## Supported Versions

Only the code in the `main` branch is actively supported for security updates.

## Secret Handling

Never commit AWS access keys, passwords, or `.tfvars` files containing sensitive data to this repository. All database credentials must be generated dynamically via the Terraform `random_password` provider and stored in AWS Secrets Manager.

## Reporting a Vulnerability

If you discover a security vulnerability within this repository, please open an issue with the label `security`. Do not publicly disclose infrastructure misconfigurations without proposing remediation.
