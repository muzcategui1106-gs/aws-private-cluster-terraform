resource "aws_subnet" "bastion_subnet" {
  availability_zone = "us-east-1a"
  cidr_block = "10.0.0.0/24"
  vpc_id = data.aws_vpc.openshift.id
  tags = {
      Name = "bastion-subnet"
  }
}

resource "aws_route_table" "private_bastion_subnet_route_table" {
  vpc_id = data.aws_vpc.openshift.id

  route {
    cidr_block        = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.vpc_igw.id
  }

  tags = {
    Name = format("bastio-subnet-route-table"),
    subnet_id = "${aws_subnet.bastion_subnet.id}"
  }
}

resource "aws_route_table_association" "private_bastion_subnet_rt_association" {
  subnet_id      = aws_route_table.private_bastion_subnet_route_table.tags["subnet_id"]
  route_table_id = aws_route_table.private_bastion_subnet_route_table.id
}

resource "aws_security_group" "bastion_sg" {
  name        = "allow_ssh"
  description = "Allow ssh to basion host"
  vpc_id      = data.aws_vpc.openshift.id

  ingress {
    description      = "ssh from anywhere"
    from_port        = 0
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion_allow_ssh"
  }
}

resource "aws_instance" "bastion" {
  ami           = "ami-0ed9277fb7eb570c9"
  instance_type = "t3.micro"

  tags = {
    Name = "bastion"
  }

  subnet_id = aws_subnet.bastion_subnet.id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name = "ocp-bastio-host-key"
}

resource "aws_eip" "bar" {
  vpc = true
  instance                  = aws_instance.bastion.id
}