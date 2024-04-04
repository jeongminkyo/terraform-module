resource "aws_iam_role" "beanstalk_service" {
  name = "aws-elasticbeanstalk-service-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "elasticbeanstalk.amazonaws.com"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "elasticbeanstalk"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role" "beanstalk_ec2" {
  name = "aws-elasticbeanstalk-ec2-role"
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "beanstalk_service" {
  name = "elastic-beanstalk-service"
  roles = [aws_iam_role.beanstalk_service.id]
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkCustomPlatformforEC2Role"
}

resource "aws_iam_policy_attachment" "beanstalk_ec2_administrator" {
  name = "elastic-beanstalk-ec2-administrator"
  roles = [aws_iam_role.beanstalk_ec2.id]
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess-AWSElasticBeanstalk"
}

resource "aws_iam_policy_attachment" "beanstalk_ec2_full_access" {
  name       = "elastic-beanstalk-ec2-full-access"
  roles      = [aws_iam_role.beanstalk_ec2.id]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_policy_attachment" "beanstalk_ec2_auto_scaling" {
  name       = "elastic-beanstalk-ec2-auto-scaling"
  roles      = [aws_iam_role.beanstalk_ec2.id]
  policy_arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
}

resource "aws_iam_policy_attachment" "beanstalk_ec2_health" {
  name       = "elastic-beanstalk-ec2-health"
  roles      = [aws_iam_role.beanstalk_ec2.id]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

resource "aws_iam_policy_attachment" "beanstalk_ec2_customer_role" {
  name       = "elastic-beanstalk-ec2-customer-role"
  roles      = [aws_iam_role.beanstalk_ec2.id]
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy"
}

resource "aws_iam_policy_attachment" "beanstalk_ec2_load_balance" {
  name       = "elastic-beanstalk-ec2-load-balance"
  roles      = [aws_iam_role.beanstalk_ec2.id]
  policy_arn = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
}

resource "aws_elastic_beanstalk_application" "jailgas-beanstalk" {
  name        = var.name
}

data "aws_elastic_beanstalk_solution_stack" "docker_latest" {
  most_recent = true
  name_regex = "^64bit Amazon Linux (.*) running Docker$"
}

resource "aws_elastic_beanstalk_environment" "jailgas-beanstalk-env" {
  name                = "${var.name}-${var.env}"
  application         = aws_elastic_beanstalk_application.jailgas-beanstalk.name
  solution_stack_name = data.aws_elastic_beanstalk_solution_stack.docker_latest.name
  tier                = "WebServer"
  tags = {
    Name             = "${var.name}-${var.env}"
    Environment      = var.env
    TerraformManaged = "true"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = var.vpc_id
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     =  "aws-elasticbeanstalk-ec2-role"
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = "aws-elasticbeanstalk-service-role"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", var.public_subnets)
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = var.instance_type
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = 1
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = 1
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = var.keypair
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = var.security_groups
  }

  ###=========================== Load Balancer ========================== ###
  
  setting {
    namespace = "aws:elbv2:listener:default"
    name      = "ListenerEnabled"
    value     = false
    }

  setting {
      namespace = "aws:elbv2:listener:443"
      name      = "ListenerEnabled"
      value     = true
  }
  setting {
      namespace = "aws:elbv2:listener:443"
      name      = "Protocol"
      value     = "HTTPS"
   }
  setting {
      namespace = "aws:elbv2:listener:443"
      name      = "SSLCertificateArns"
      value     = var.certificate
  }
  setting {
      namespace = "aws:elbv2:listener:443"
      name      = "SSLPolicy"
      value     = "ELBSecurityPolicy-2016-08"

  }
  setting {
      namespace = "aws:elasticbeanstalk:environment:process:default"
      name      = "HealthCheckPath"
      value     = "/"
  }
  setting {
      namespace = "aws:elasticbeanstalk:environment:process:default"
      name      = "Port"
      value     = 80
  }
  setting {
      namespace = "aws:elasticbeanstalk:environment:process:default"
      name      = "Protocol"
      value     = "HTTP"
  }


}

resource "aws_lb_listener" "https_redirect" {
  load_balancer_arn = aws_elastic_beanstalk_environment.jailgas-beanstalk-env.load_balancers[0]
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

data "aws_lb" "eb_lb" {
  arn = aws_elastic_beanstalk_environment.jailgas-beanstalk-env.load_balancers[0]
}

resource "aws_security_group_rule" "allow_80" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = tolist(data.aws_lb.eb_lb.security_groups)[0]
}
