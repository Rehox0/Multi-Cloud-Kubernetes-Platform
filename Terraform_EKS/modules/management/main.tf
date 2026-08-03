resource "aws_launch_template" "management" {
  name_prefix   = "mgmt-template-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  iam_instance_profile {
    name = var.instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.management_sg_id]
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh.tftpl", {
    kubectl_version   = var.kubectl_version
    kubectl_sha256    = var.kubectl_sha256
    helm_version      = var.helm_version
    helm_sha256       = var.helm_sha256
    ssh_public_keys   = var.ssh_public_keys
    aws_region        = var.aws_region
    cluster_name      = var.cluster_name
  }))
}

resource "aws_autoscaling_group" "management" {
  name                = "mgmt-asg"
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1
  vpc_zone_identifier = var.subnet_ids

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 1
      on_demand_percentage_above_base_capacity = 100
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.management.id
        version            = "$Latest"
      }
    } 
  } 
}
