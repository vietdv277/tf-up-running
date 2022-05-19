provider "aws" {
  region = "ap-southeast-1"
}

module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  cluster_name = "webservers-stage"
  db_remote_state_bucket = "terraform-up-and-running-state-vietdv"
  db_remote_state_key = "stage/data-stores/mysql/terraform.tfstate"

  instance_type = "t1.micro"
  min_size = 2
  max_size = 2
}

resource "aws_security_group_rule" "alb_allow_https_inbound" {
  type = "ingress"
  security_group_id = module.webserver_cluster.alb_security_group_id

  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  }
