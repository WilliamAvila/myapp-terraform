data "aws_vpc" "default" {
  default = true
}
resource "aws_security_group" "my_sg" {
  vpc_id      = data.aws_vpc.default.id
  name        = "postgres_sg"
  description = "Allow all inbound for Postgres"
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_db_instance" "default_postgres" {
  identifier                 = "${var.app_name}-${terraform.workspace}-postgres"
  instance_class             = var.rds_instance_class
  allocated_storage          = var.rds_allocated_storage
  engine                     = "postgres"
  engine_version             = "14"
  auto_minor_version_upgrade = false
  skip_final_snapshot        = var.skip_final_snapshot
  publicly_accessible        = true
  vpc_security_group_ids     = [aws_security_group.my_sg.id]
  username                   = var.postgres_admin_username
  password                   = var.postgres_admin_password
}

output "postgres_id" {
  value = aws_db_instance.default_postgres.id
}

output "postgres_address" {
  value = aws_db_instance.default_postgres.address
}