provider "aws" {
  region = "ap-southeast-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  owners = [ "099720109477" ] # Canonical
}

resource "aws_key_pair" "vietdv-iMac" {
  key_name = "vietdv-iMac-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCaw2/4a/DWOqMwcPdg5mHXBG0zkgtm2uFT6+mz9xD2SRwbC0TMPrn+eCOK9qy/VQhDX21fdJK1QoNvJ6V/TrKXXbtRFdDsyZR0WOITwZiMoPqs+/lxVgNDNUPFuwFpN9jfr/wph67lPJ35/AgjGlGyquWIV+VWRhqNIYkeogBY7nqfVSCMDCEdI4ol12PxPvBiAixaAid0MYbxMLpIxdY3ItvFnF+9SZWsdxRK7osIdVZph8DFzNUJZrIx+rzpW/IoKDFwrdYYF20R9KVXE7jdyo86x/AI31nxohsamKZCB7/VtZg7O6chjtYJqKfAkc/0KFCG8p5xLjS1MKlkU/OL1XMFHD0C2BjcZ+tNpbdSROjE83vzj7okFIeh2eE25U6wplX3FIr1RJZe5h+izZy5k1wG5qV79E33kXOp4ACNTZV8C4RWs5488O3ZoObMd7dz7LcK619QvyiUERfeBzozIG3E6eCYLV9TrN0m42HZlYb4zWl9Fd5LQnjavRmLXYEqj8BnBamVt2H1FntsyGOM2NT1XnMDVEELxfr9yuFVRZONLQykh65UvBW0LImbbqNTKaQl0NL15JhWCY1Seo+EOn9aOFyp/faYenW+MYD/JLBBzbGBxztwSMm+2IjP5vd2QWdRk00be1ReEXu0H+yhigND1G0n1hilQsTTE2D3xQ=="
}

resource "aws_security_group" "sg-webserver" {
  name = "tf-getting-started-instance"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "instance" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name = "vietdv-iMac-key"
  vpc_security_group_ids = [aws_security_group.sg-webserver.id]

  user_data = <<-EOF
  #!/bin/bash -xe
  
  sudo apt-get update
  sudo apt-get install -y net-tools
  sudo apt-get install -y apache2
  sudo systemctl start apache2
  sudo systemctl enable apache2
  echo "The page was created by the user data" | sudo tee /var/www/html/index.html
  EOF
  tags = {
    Name = "00-getting-started"
  }
}
