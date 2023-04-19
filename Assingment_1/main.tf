provider "aws" {
  region = "us-east-1"
}

#VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  instance_tenancy = "default"
  tags = {
    Name = "my-vpc_ASG"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1d"

  tags = {
    Name = "my_subnet"
  }
}

resource "aws_security_group" "vpc_security_group" {
  name_prefix = "my-security-group"
  description = "My security group"

  ingress {
    from_port   = 0
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_internet_gateway" "my_internet_gateway" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my-internet-gateway" 
  }
}

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_internet_gateway.id
  }

  tags = {
    Name = "my-route-table"
  }
}

resource "aws_route_table_association" "my_route_table_association" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.my_route_table.id
}


# Create a launch configuration and attach the security group
resource "aws_launch_configuration" "example_lc" {
  name_prefix          = "Demo-lc"
  image_id             = "ami-007855ac798b5175e"
  instance_type        = "t2.micro"
  lifecycle {
    create_before_destroy = true
  }
}

# Create an auto scaling group using the launch configuration
resource "aws_autoscaling_group" "example_asg" {
  name                      = "Demo-asg"
  vpc_zone_identifier       = [aws_subnet.subnet.id]
  launch_configuration      = aws_launch_configuration.example_lc.id
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  termination_policies      = ["OldestInstance", "Default"]
  target_group_arns         = [aws_lb_target_group.Demo_target_group.arn]
  
  tag {
    key                 = "Name"
    value               = "my-instance"
    propagate_at_launch = true
  }
}

#create target gp 
resource "aws_lb_target_group" "Demo_target_group" {
  name     = "example"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id
}
#create ELB and attached to asg
resource "aws_elb" "example_elb" {
  name            = "example-elb"
  subnets         = [aws_subnet.subnet.id]
  security_groups = [aws_security_group.vpc_security_group.id]

  listener {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }

  health_check {
    target              = "HTTP:80/"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }
}

#create security group for rds
resource "aws_security_group" "rds" {
  name_prefix = "rds_"
  vpc_id   = aws_vpc.my_vpc.id
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an S3 bucket for backups
resource "aws_s3_bucket" "rds_backup_bucket" {
  bucket = "my-rds-backup-bucket"
}

# Create an RDS instance with S3 backup
resource "aws_db_instance" "my_rds_instance" {
  identifier             = "my-rds-instance"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  db_name                = "mydatabase"
  username               = "mayur"
  password               = "mayur123"
  parameter_group_name     = "default.mysql5.7"
  backup_retention_period  = 7
  vpc_security_group_ids   = [aws_security_group.rds.id]
  db_subnet_group_name     = aws_db_subnet_group.SB.name
  skip_final_snapshot      = true
  tags = {
    Name = "My RDS Instance"
  }

}

resource "aws_subnet" "rds_SB1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "rds_subnet1"
  }
}
resource "aws_subnet" "rds_SB2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1c"
  tags = {
    Name = "rds_subnet1"
  }
}

#db subnet group name
resource "aws_db_subnet_group" "SB" {
  name        = "example-db-subnet-group"
  subnet_ids = [aws_subnet.rds_SB1.id, aws_subnet.rds_SB2.id]
  tags = {
    Name = "example-db-subnet-group"
  }
}

resource "aws_db_snapshot" "rds_backup" {
  db_instance_identifier = aws_db_instance.my_rds_instance.id
  db_snapshot_identifier = "testsnapshot1234"
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.rds_backup_bucket.id
  acl    = "private"
}

resource "aws_iam_role" "example" {
  name = "example"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "export.rds.amazonaws.com"
        }
      },
    ]
  })
}

data "aws_iam_policy_document" "example" {
  statement {
    actions = [
      "s3:ListAllMyBuckets",
    ]
    resources = [
      "*"
    ]
  }
  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.rds_backup_bucket.arn,
    ]
  }
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = [
      "${aws_s3_bucket.rds_backup_bucket.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "example" {
  name   = "example"
  policy = data.aws_iam_policy_document.example.json
}

resource "aws_iam_role_policy_attachment" "example" {
  role       = aws_iam_role.example.name
  policy_arn = aws_iam_policy.example.arn
}

resource "aws_kms_key" "example" {
  deletion_window_in_days = 10
}

resource "aws_rds_export_task" "example" {
  export_task_identifier = "example"
  source_arn             = aws_db_snapshot.rds_backup.db_snapshot_arn
  s3_bucket_name         = aws_s3_bucket.rds_backup_bucket.id
  iam_role_arn           = aws_iam_role.example.arn
  kms_key_id             = aws_kms_key.example.arn

  export_only = ["database"]
  s3_prefix   = "my_prefix/example"
}
