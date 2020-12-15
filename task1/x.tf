# Configure the AWS Provider
provider "aws" {
  version = "~> 3.0"
  region  = "ap-south-1"
  access_key = "AKIAU57BYUI2N4QVJ4NU"
  secret_key = "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"
}

resource "aws_security_group" "morning-ssh-http" {
  name        = "morning-ssh-http"
  description = "allow ssh and http traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "good-morning" {
  ami               = "ami-5b673c34"
  instance_type     = "t2.micro"
  availability_zone = "ap-south-1a"
  security_groups   = ["${aws_security_group.morning-ssh-http.name}"]
  #key_name = "zoomkey"
  user_data = <<-EOF
                #! /bin/bash
                sudo yum install httpd -y
                sudo systemctl start httpd
                sudo systemctl enable httpd
                echo -e '<!DOCTYPE html>\n<html>\n\t<head>\n\t\t<title>Hello World!</title>\n\t</head>\n\t<body>\n\t\tHello World!\n\t</body>\n</html>' | sudo tee /var/www/html/index.html

  EOF


  tags = {
        Name = "webserver"
  }

}

output "DNS" {
  value = aws_instance.good-morning.public_dns
}
