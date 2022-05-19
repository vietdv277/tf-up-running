provider "aws" {
  region = "ap-southeast-1"
}

terraform {
  required_version = "~> 1.1.7"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
   bucket = "terraform-up-and-running-state-vietdv"
   key = "global/iam/terraform.tfstate"
   region = "ap-southeast-1"

   dynamodb_table = "terraform-up-and-running-locks"
   encrypt = true
  }
}

resource "aws_key_pair" "vietdv-iMac" {
  key_name = var.key_pair_name
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCaw2/4a/DWOqMwcPdg5mHXBG0zkgtm2uFT6+mz9xD2SRwbC0TMPrn+eCOK9qy/VQhDX21fdJK1QoNvJ6V/TrKXXbtRFdDsyZR0WOITwZiMoPqs+/lxVgNDNUPFuwFpN9jfr/wph67lPJ35/AgjGlGyquWIV+VWRhqNIYkeogBY7nqfVSCMDCEdI4ol12PxPvBiAixaAid0MYbxMLpIxdY3ItvFnF+9SZWsdxRK7osIdVZph8DFzNUJZrIx+rzpW/IoKDFwrdYYF20R9KVXE7jdyo86x/AI31nxohsamKZCB7/VtZg7O6chjtYJqKfAkc/0KFCG8p5xLjS1MKlkU/OL1XMFHD0C2BjcZ+tNpbdSROjE83vzj7okFIeh2eE25U6wplX3FIr1RJZe5h+izZy5k1wG5qV79E33kXOp4ACNTZV8C4RWs5488O3ZoObMd7dz7LcK619QvyiUERfeBzozIG3E6eCYLV9TrN0m42HZlYb4zWl9Fd5LQnjavRmLXYEqj8BnBamVt2H1FntsyGOM2NT1XnMDVEELxfr9yuFVRZONLQykh65UvBW0LImbbqNTKaQl0NL15JhWCY1Seo+EOn9aOFyp/faYenW+MYD/JLBBzbGBxztwSMm+2IjP5vd2QWdRk00be1ReEXu0H+yhigND1G0n1hilQsTTE2D3xQ=="
}

