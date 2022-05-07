provider "aws" {
  region = "ap-southeast-1"
}

terraform {
  backend "s3" {
    bucket = "terraform-up-and-running-state-vietdv"
    key = "stage/data-stores/mysql/terraform.tfstate"
    region = "ap-southeast-1"

    dynamodb_table = "terraform-up-and-running-locks"
    encrypt = true
  }
}

resource "aws_db_instance" "example" {
  identifier_prefix = "tf-up-running"
  engine = "mysql"
  allocated_storage = 10
  instance_class = "db.t2.micro"
  skip_final_snapshot = true
  db_name = "example_database"

  username = var.db_username
  password = var.db_password
}

