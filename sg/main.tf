
# security groups
resource "aws_security_group" "ssh" {
  name        = "${var.name}-ssh"
  description = "Security group for ssh"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.cidr]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name             = "${var.name}-ssh"
    Environment      = var.env
    TerraformManaged = "true"
  }
}


resource "aws_security_group" "db" {
  name        = "${var.name}-db"
  description = "Security group for db"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.cidr]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name             = "${var.name}-db"
    Environment      = var.env
    TerraformManaged = "true"
  }
}
