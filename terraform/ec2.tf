data "aws_ami" "gpterror" {
  most_recent = true
  owners = ["self"]

  filter {
    name   = "name"
    values = ["gpterror-*"]
  }
}

resource "aws_launch_template" "this" {
  name = local.var.project_name
  image_id = data.aws_ami.gpterror.id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = local.var.ec2_instance_type
  vpc_security_group_ids = [aws_security_group.this.id]

  instance_market_options {
    market_type = local.var.ec2_market_type
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.launch_template.name
  }
}

resource "aws_autoscaling_group" "this" {
  name                      = local.var.project_name
  max_size                  = 1
  min_size                  = 0
  health_check_grace_period = 30
  health_check_type         = "ELB"
  desired_capacity          = 0
  force_delete              = true
  vpc_zone_identifier       = [aws_subnet.public.id]

  launch_template {
    id = aws_launch_template.this.id
    version = "$Latest"
  }
  lifecycle {
    ignore_changes = [
      desired_capacity
    ]
  }
}
