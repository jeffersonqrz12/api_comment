resource "aws_instance" "api" {
  ami  = "ami-04b70fa74e45c3917" # us-west-2
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ssh.id]

  
#script para instalar, fazer o pull da imagem da api no docker hub e executar a api 
  user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
    sudo apt update -y
    sudo apt install docker-ce -y
    sudo usermod -aG docker ubuntu
    sudo docker pull jeffersonqrz1/api_comment:lates
    sudo docker run -d -p 5000:5000 jeffersonqrz1/api_comment

    EOF
}



resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = "myKey"       # cria a chave .pem
  public_key = tls_private_key.pk.public_key_openssh

  provisioner "local-exec" { # envia a chave .pem para a sua instancia
    command = "echo '${tls_private_key.pk.private_key_pem}' > $PWD/myKey.pem"
  }
}

resource "aws_security_group" "ssh"{
    name = "ssh"
    description = "ssh SG"
    

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]

    }
  
    ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
