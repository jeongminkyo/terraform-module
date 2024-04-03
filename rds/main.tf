data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_db_subnet_group" "subnet_group" {
  name       = "${var.name}-db-subnet"
  subnet_ids = var.private_rds_subnets_id

  tags = {
    Name             = "${var.name}-db-subnet"
	Environment      = var.env
    TerraformManaged = "true"
  }
}

resource "aws_db_parameter_group" "parameter_group" {
  name   = "parameter-group-korean"
  
  # Please change this value to version you want to use 
  family = "mysql8.0"
  
  # From this, you could override the default value of DB parameter
  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_connection"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_filesystem"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_results"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  tags = {
    Name             = "parameter-group-korean"
	Environment      = var.env
    TerraformManaged = "true"
  }
}

resource "aws_db_instance" "rds" {
  allocated_storage           = var.rds_storage
  max_allocated_storage       = var.rds_storage
  availability_zone           = data.aws_availability_zones.available.names[0]
  db_subnet_group_name        = aws_db_subnet_group.subnet_group.name
  parameter_group_name        = aws_db_parameter_group.parameter_group.name
  engine                      = var.db_engine
  engine_version              = var.db_engine_version
  instance_class              = var.db_instance_class
  skip_final_snapshot         = true
  identifier                  = "${var.name}-db"
  username                    = var.db_user_name
  password                    = var.db_password
  db_name                     = var.database_name
  port                        = var.database_port
  auto_minor_version_upgrade  = false

  vpc_security_group_ids = [
    var.security_groups_id
  ]

  tags = {
    Name             = "${var.name}-db"
	Environment      = var.env
    TerraformManaged = "true"
  }
}
