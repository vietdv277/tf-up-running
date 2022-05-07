variable "db_remote_state_bucket" {
  description = "The name of S3 bucket used for the database's remote state storage"
  type = string
  default = "terraform-up-and-running-state-vietdv"
}

variable "db_remote_state_key" {
  description = "The name of key in the S3 bucket used for database's remote state storage"
  type = string
  default = "stage/data-stores/mysql/terraform.tfstate"
}