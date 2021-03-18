
resource "aws_launch_template" "main" {
  name             = "Version1"
  image_id         = var.ami
  instance_type    = "t2.micro"
  key_name         = "Tinorudy"
  instance_initiated_shutdown_behavior = "terminate"
  vpc_security_group_ids = [var.security_groups_id]
  update_default_version = true
  user_data = filebase64("../Modules/asg/bootstrap.sh")
  
}

resource "aws_autoscaling_group" "asg" {
  name                         = "asg"
  vpc_zone_identifier          = var.subnet_id
  max_size                     = 4
  min_size                     = 2
  health_check_grace_period    = 300
  force_delete                 = true
  desired_capacity             = 2

  launch_template {
    id =   var.aws_launch_template_id
    version = "$Latest"
  }
}