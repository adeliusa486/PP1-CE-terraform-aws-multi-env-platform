# Contributing Guidelines

## Pull Request Process

1. Create a feature branch from `main`.
2. Ensure all Terraform code is formatted by running `terraform fmt -recursive`.
3. Ensure all modules pass `terraform validate`.
4. Open a Pull Request. The GitHub Actions CI pipeline will automatically run formatting and validation checks.
5. Do not run `terragrunt apply` from your local machine against the production environment.
