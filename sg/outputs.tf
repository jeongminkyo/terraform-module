output "http" {
  value = aws_security_group.http.id
}

output "instance" {
  value = aws_security_group.instance.id
}

output "db" {
  value = aws_security_group.db.id
}

output "ssh" {
  value = aws_security_group.ssh.id
}

output "ec2_security_groups" {
  value = [aws_security_group.ssh.id, aws_security_group.instance.id]
}

output "lb_security_groups" {
  value = [aws_security_group.http.id]
}
