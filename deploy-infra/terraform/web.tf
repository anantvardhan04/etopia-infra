resource "aws_launch_configuration" "etopia-app-lc" {
  name_prefix = format("etopia-%s-lc", var.environment)
  image_id = var.app_ami_id
  instance_type = var.app_instance_type
  key_name = var.app_key_name
  security_groups = [
    var.rds_db_client_sg,
    var.app_sg
  ]
  lifecycle {
    create_before_destroy = true
  }
  root_block_device {
    volume_type = "gp2"
    volume_size = "20"
  }
}

resource "aws_autoscaling_group" "etopia-autoscaling-group" {
  name = format("etopia-%s-asg", var.environment)
  vpc_zone_identifier = var.private_subnets
  launch_configuration = aws_launch_configuration.etopia-app-lc.name
  min_size = var.app_instances_count
  desired_capacity = var.app_instances_count
  max_size = var.app_instance_max
  health_check_grace_period = 300
  health_check_type = "ELB"
  target_group_arns = [var.app_alb_target_group]
  force_delete = true
  termination_policies = [
    "OldestLaunchConfiguration"]
  tag {
    key                 = "Name"
    value               = format("etopia-%s-asg", var.environment)
    propagate_at_launch = true
  }
  tag {
    key                 = "Owner"
    value               = var.tags["owner"]
    propagate_at_launch = true
  }
  tag {
    key                 = "CostCenter"
    value               = var.tags["cost_center"]
    propagate_at_launch = true
  }
  tag {
    key                 = "Environment"
    value               = var.tags["environment"]
    propagate_at_launch = true
  }
  tag {
    key                 = "Project"
    value               = var.tags["project"]
    propagate_at_launch = true
  }
}

// Autoscaling policies
resource "aws_autoscaling_policy" "etopia-autoscaling-policy-up" {
  name = format("etopia-%s-autoscaling-policy-up", var.environment)
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = aws_autoscaling_group.etopia-autoscaling-group.name
}

resource "aws_autoscaling_policy" "etopia-autoscaling-policy-down" {
  name = format("etopia-%s-autoscaling-policy-down", var.environment)
  scaling_adjustment = -1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = aws_autoscaling_group.etopia-autoscaling-group.name
}