output "cname" {
  value       = aws_elastic_beanstalk_environment.jailgas-beanstalk-env.cname
}

output "envName" {
  value       = aws_elastic_beanstalk_environment.jailgas-beanstalk-env.name
}

output "asgName" {
    value = aws_elastic_beanstalk_environment.jailgas-beanstalk-env.autoscaling_groups[0]
}


output "lbarn" {
    value = aws_elastic_beanstalk_environment.jailgas-beanstalk-env.load_balancers[0]
}
