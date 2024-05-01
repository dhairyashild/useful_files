# vpc
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_sub_1a" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "Main"
  }
}


#pub-sub
resource "aws_subnet" "public_sub_1b" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "Main"
  }
}

#pvt-sub
resource "aws_subnet" "private_sub_1a" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "Main"
  }
}


resource "aws_subnet" "private_sub_1b" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "Main"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

#pub-rt
resource "aws_route_table" "rt_pub" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }



  tags = {
    Name = "rtpub"
  }
}



#pub-rt and sub association
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_sub_1a.id
  route_table_id = aws_route_table.rt_pub.id
}
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public_sub_1b.id
  route_table_id = aws_route_table.rt_pub.id
}
# pvt-rt and sub association
resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.private_sub_1a.id
  route_table_id = aws_route_table.rt-pvt.id
}
resource "aws_route_table_association" "d" {
  subnet_id      = aws_subnet.private_sub_1b.id
  route_table_id = aws_route_table.rt-pvt.id
}


#nat
resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.lb.id
  subnet_id     = aws_subnet.public_sub_1a.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}

# eip
resource "aws_eip" "lb" {
  domain   = "vpc"
}

#private rt
resource "aws_route_table" "rt-pvt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.example.id
      }

  tags = {
    Name = "example"
  }
}
