variable "app_name" {
  default = "myapp"
}
variable "region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}
variable "ecr_image" {
  default = "PLACEHOLDER"
}


#Terraform Backend Setup with S3 and DynamoDB
variable "s3_bucket_backend" {
  default = "PLACEHOLDER"
}

variable "dynamodb_backend" {
  default = "PLACEHOLDER"
}

#RDS Instance Settings
variable "postgres_admin_username" {
  default = "PLACEHOLDER"
}
variable "postgres_admin_password" {
  default = "PLACEHOLDER"
}
variable "rds_allocated_storage" {
  default = "5"
}
variable "rds_instance_class" {
  default = "db.t3.micro"
}
variable "rds_multi_az" {
  default = "false"
}
variable "skip_final_snapshot" {
  default = "true"
}

#CodeBuild config
variable "codestar_arn" {
  default = "PLACEHOLDER"
}
variable "PORT" {
  default = "PLACEHOLDER"
}
variable "PG_HOST" {
  default = "PLACEHOLDER"
}
variable "PG_PORT" {
  default = "PLACEHOLDER"
}
variable "POSTGRES_USER" {
  default = "PLACEHOLDER"
}
variable "POSTGRES_PASSWORD" {
  default = "PLACEHOLDER"
}
variable "POSTGRES_DB" {
  default = "PLACEHOLDER"
}
variable "JWT_SECRET" {
  default = "PLACEHOLDER"
}
variable "JWT_EXPIRATION" {
  default = "PLACEHOLDER"
}
variable "github_credentials" {
  type = map(string)
  default = {
    token     = ""
    user_name = ""
  }
}