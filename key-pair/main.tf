# Generates a secure private key and encodes it as PEM
resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create the Key Pair
resource "aws_key_pair" "jailgas-ssh-key" {
  key_name   = var.name
  public_key = tls_private_key.key_pair.public_key_openssh
  
  tags = {
    Name             = "${var.name}-ssh-key"
    Environment      = var.env
    TerraformManaged = "true"
  }
}