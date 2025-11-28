data "aws_ami" "os_image" {
  owners      = ["099720109477"]
  most_recent = true

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/*24.04-amd64*"]
  }
}

resource "aws_key_pair" "key_pair" {
  key_name   = "fullstack_Chatapp"
  public_key = file("fullstack_Chatapp.pub")
}


resource "aws_security_group" "sg" {
  name        = "allow TLS"
  description = "Allow user to connect"

  vpc_id = module.vpc.vpc_id

  dynamic "ingress" {
    for_each = [
      { description = "port 22 allow", from = 22, to = 22, protocol = "tcp", cidr = ["0.0.0.0/0"] },
      { description = "port 80 allow", from = 80, to = 80, protocol = "tcp", cidr = ["0.0.0.0/0"] },
      { description = "port 443 allow", from = 443, to = 443, protocol = "tcp", cidr = ["0.0.0.0/0"] },
      { description = "port 8080 allow", from = 8080, to = 8080, protocol = "tcp", cidr = ["0.0.0.0/0"] },
      { description = "port 9000 allow", from = 9000, to = 9000, protocol = "tcp", cidr = ["0.0.0.0/0"] }
    ]
    content {
        description =  ingress.value.description
        from_port =  ingress.value.from
        to_port =  ingress.value.to
        protocol = ingress.value.protocol
        cidr_blocks =  ingress.value.cidr
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "mysecurity"
  }
}


# resource "aws_instance" "myinstance" {
#   ami                    = data.aws_ami.os_image.id
#   instance_type          = "t2.large"
#   key_name               = aws_key_pair.key_pair.key_name
#   vpc_security_group_ids = [aws_security_group.sg.id]
#   subnet_id              = module.vpc.public_subnets[0]

#   root_block_device {
#     volume_size = 30
#     volume_type = "gp3"
#   }

#   tags = {
#     Name = "jenkins Automate"
#   }
# }


# resource "aws_eip" "server_ip" {
#   instance = aws_instance.myinstance.id 
#   domain = "vpc"
# }

# resource "aws_ec2_instance_state" "state" {
#   instance_id = aws_instance.myinstance.id
#   state = "stopped"
# }