#Create private key
resource "tls_private_key" "packer_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "packer_key_pair" {
  key_name   = var.packerKeyName
  public_key = tls_private_key.packer_private_key.public_key_openssh
}

resource "aws_vpc" "packer_vpc" {
  cidr_block = "1.0.0.0/24"

  tags = {
    Name    = "udemyLearnPacker"
    service = "packerBuildDeployVPC"
  }
}

resource "aws_subnet" "packer_subnet" {
  vpc_id                   = aws_vpc.packer_vpc.id
  cidr_block               = "1.0.0.0/24"
  map_public_ip_on_launch  = true

  tags = {
    Name    = "Packer build and deploy"
    service = "packerBuildDeploySubnet"
  }
}

resource "aws_internet_gateway" "packer_internet_gateway" {
  vpc_id = aws_vpc.packer_vpc.id
}

resource "aws_route" "packer_internet_access" {
  route_table_id         = aws_vpc.packer_vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.packer_internet_gateway.id
}

resource "aws_security_group" "packer_security_group" {
  name        = "packer allow web traffic"
  description = "Allow HTTP:80 and RDP:3389 traffic"
  vpc_id      = aws_vpc.packer_vpc.id

  tags = {
    Name    = "Packer build and deploy"
    service = "packerBuildDeploySecurityGroup"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
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