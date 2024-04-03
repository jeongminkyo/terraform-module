output "db" {
  value = aws_security_group.db.id
}

output "ssh" {
  value = aws_security_group.ssh.id
}

output "ec2_security_groups" {
  value = [aws_security_group.ssh.id]
}
