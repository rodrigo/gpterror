resource "aws_cloudwatch_metric_alarm" "less-than-or-equal-to-80" {
  alarm_name                = "ASG: GPTerror objects less or equal than 80"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "s3-objects-count"
  namespace                 = "gpterror"
  period                    = 60
  statistic                 = "Maximum"
  threshold                 = 80
  treat_missing_data = "ignore"
  alarm_actions = [aws_autoscaling_policy.increase-capacity.arn]
}

resource "aws_autoscaling_policy" "increase-capacity" {
  name                   = "Escalar ASG"
  scaling_adjustment     = 1
  adjustment_type        = "ExactCapacity"
  cooldown               = 30
  autoscaling_group_name = aws_autoscaling_group.this.name
}

resource "aws_cloudwatch_metric_alarm" "higher-than-98" {
  alarm_name                = "ASG: GPTerror objects higher than 98"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 1
  metric_name               = "s3-objects-count"
  namespace                 = "gpterror"
  period                    = 60
  statistic                 = "Maximum"
  threshold                 = 98
  treat_missing_data = "ignore"
  alarm_actions = [aws_autoscaling_policy.decrease-capacity.arn]
}

resource "aws_autoscaling_policy" "decrease-capacity" {
  name                   = "Reduzir ASG"
  scaling_adjustment     = 0
  adjustment_type        = "ExactCapacity"
  cooldown               = 30
  autoscaling_group_name = aws_autoscaling_group.this.name
}
