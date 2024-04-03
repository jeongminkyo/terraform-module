# aws_key_pair resource 
resource "aws_key_pair" "jailgas-ssh-key" {
  key_name   = var.name

  public_key = file("../../../../ssh/${var.name}-ssh-key.pub")
  
  tags = {
    Name             = "${var.name}-ssh-key"
    Environment      = var.env
    TerraformManaged = "true"
  }
}
