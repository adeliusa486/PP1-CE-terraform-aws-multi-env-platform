# Create the DB Subnet Group (Tells RDS which VLANs it is allowed to use)
resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = var.private_subnet_ids
}

# Generate a cryptographically secure random password
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Create the vault in AWS Secrets Manager
resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "${var.environment}-db-credentials"
  recovery_window_in_days = 0
}

# Store the password securely in the vault
resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = "dbadmin"
    password = random_password.db_password.result
  })
}

# Create the RDS Instance
resource "aws_db_instance" "main" {
  identifier        = "${var.environment}-mysql"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = "appdb"
  username = "dbadmin"
  password = random_password.db_password.result

  db_subnet_group_name = aws_db_subnet_group.main.name
  multi_az             = var.multi_az

  skip_final_snapshot = true # Set to false in a real production environment
}