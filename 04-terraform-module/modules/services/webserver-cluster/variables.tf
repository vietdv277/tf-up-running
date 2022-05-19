variable "cluster_name" {
  description = "The name to use for all cluster resources"
  type = string
}

variable "db_remote_state_bucket" {
  description = "The name of S3 bucket used for the database's remote state storage"
  type = string
}

variable "db_remote_state_key" {
  description = "The name of key in the S3 bucket used for database's remote state storage"
  type = string
}

variable "instance_type" {
  description = "The type of EC2 instances"
  type = string
  default = "t2.micro"
}

variable "ssh_key_name" {
  description = "The name of ssh key"
  type = string
  default = "vietdv-iMac"
}

variable "min_size" {
  description = "The Minimum number of EC2 instances in ASG"
  type = number
}

variable "max_size" {
  description = "The Maximum number of EC2 instances in ASG"
  type = number
}

variable "server_port" {
  description = "HTTP port of web servers"
  type = number
  default = 80
}
