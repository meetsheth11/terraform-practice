data "aws_ami" "server_ami" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

resource "aws_key_pair" "meet_auth" {
  key_name   = "meetkey"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDPNCctCU9mTaDDzQbAPe5DNvXtQIHYi6t9+4pja7kKvFH6Xve0gpNfa34VBc+7B1vaoygU7AQCZb9+v2Q2icU6xmdxJFCiPhc9QxK4OFdkQVoQALX+FjJn5I1xicKCS60vqjGZYqZF9FliHsOQBjhgZJTGo/UhyqTU/znAPmyZQ3T1UO3L9XJPDhhFaUGR02m4Jn5xiUyITcjaYsOWIjpfLwaGiDjR110fdkwAQBcKuIQTN5m2deT6DG/3L2EblIHA6Ycit5r7gVJJy7lfXpqffzDV2OIxlcDudI14xXZ9vcCMMYjylxcIQzEmcdpFG/hZ5VvhDUnHNaiNoFGB2nrg3sdtby8jQIPhWzM0CI0YM6X6E1R2veVPPHcekns3F7CO+06BZBYF8kjOrfQOlIS5HnZTm+Jk5DUZPLksfoPgoCSneT6Zxf7gCfefS0bz3XvYnk7TcWHzNjZz8hSYA+10nquI7y70+KreIh5DMlYmNwtxtI6O4bo881k3RF68WnM= sheth@192.168.1.2"
}

resource "aws_instance" "meet_node" {
  instance_type = "t2.micro"
  ami           = data.aws_ami.server_ami.id

  tags = {
    Name = "meet_node"
  }

  key_name               = aws_key_pair.meet_auth.id
  vpc_security_group_ids = [var.meet_public_sg]
  subnet_id              = var.public_subnets[0]
  user_data              = templatefile("userdata.tpl",{})

  root_block_device {
    volume_size = var.vol_size
  }
}