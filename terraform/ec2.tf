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

data "aws_ami" "cert_renewer" {
  most_recent = true
  owners = ["self"]

  filter {
    name   = "name"
    values = ["cert-renew-*"]
  }
}

resource "aws_launch_template" "cert_renewer" {
  name = "cert_renewer"
  image_id = data.aws_ami.cert_renewer.id
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

resource "aws_autoscaling_group" "cert_renewer" {
  name                      = "cert_renewer"
  max_size                  = 0
  min_size                  = 0
  health_check_grace_period = 30
  health_check_type         = "ELB"
  desired_capacity          = 0
  force_delete              = true
  vpc_zone_identifier       = [aws_subnet.public.id]

  launch_template {
    id = aws_launch_template.cert_renewer.id
    version = "$Latest"
  }
  lifecycle {
    ignore_changes = [
      desired_capacity
    ]
  }
}

resource "aws_autoscaling_schedule" "increase_capacity" {
  scheduled_action_name  = "Increase Capacity"
  min_size               = 1
  max_size               = 1
  desired_capacity       = 1
  recurrence = "0 23 */5 * *" #UTC
  autoscaling_group_name = aws_autoscaling_group.cert_renewer.name
}

resource "aws_autoscaling_schedule" "decrease_capacity" {
  scheduled_action_name  = "Decrease Capacity"
  min_size               = 0
  max_size               = 0
  desired_capacity       = 0
  recurrence = "10 23 */5 * *" #UTC
  autoscaling_group_name = aws_autoscaling_group.cert_renewer.name
}
