provider "aws" {
  profile  =  "YOUR-PROFILE"
  region  = "us-east-1"
}

resource "aws_vpc" "myvpc" {
  cidr_block = "192.178.0.0/16"
    enable_dns_hostnames = "true"
   tags = {
    Name = "terra-vpc"
  }
}



resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "192.178.0.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "terra-public"
  }
}



resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "192.178.1.0/24"
    availability_zone = "us-east-1b"

  tags = {
    Name = "terra-private"
  }
}


resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "terra-gateway"
  }
}



resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.myvpc.id

route {
    cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.gw.id
}
   
 tags = {
    Name = "main"
  }
}


resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.r.id
}



resource "aws_security_group" "allowssh" {
  name        = "allowssh"
  description = "Allow TLS inbound traffic"
  vpc_id      =  aws_vpc.myvpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public"
  }
}


resource "aws_security_group" "allowsql" {
  name        = "allowsql"
  description = "Allow TLS inbound traffic"
  vpc_id      =  aws_vpc.myvpc.id


 ingress {
    description = "mysql-rule"
    from_port   = 3306
    to_port     = 3306                                           
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private"
  }
}



resource "aws_instance" "wp" {
  ami           = "ami-00635c89bef056895"
  instance_type = "t2.micro"
  subnet_id  =  aws_subnet.subnet1.id
  vpc_security_group_ids  =  ["${aws_security_group.allowssh.id}"]
  key_name  = "ec2_key"
  

  tags = {
    Name = "terra-wp"
  }
}


resource "aws_instance" "sql" {
  ami           = "ami-052c62a59dc2e8jud"
  instance_type = "t2.micro"
  subnet_id  =  aws_subnet.subnet2.id
  vpc_security_group_ids  =  ["${aws_security_group.allowsql.id}"]
  key_name  = "ec2_key"
  

  tags = {
    Name = "terra-sql"
  }
}
