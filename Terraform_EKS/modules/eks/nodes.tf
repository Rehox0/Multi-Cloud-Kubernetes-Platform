resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-nodes"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids

  capacity_type  = var.node_capacity_type
  instance_types = var.node_instance_types

  launch_template {
      id      = aws_launch_template.nodes.id
      version = aws_launch_template.nodes.latest_version
    }
  
  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  update_config {
    max_unavailable = var.node_max_unavailable
  }

  labels = merge(
    {
      role = "worker"
    },
    var.node_labels
  )

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-node-group"
  })
}

resource "aws_launch_template" "nodes" {
  name_prefix = "${var.project_name}-nodes-"

  user_data = base64encode(<<-EOF
    MIME-Version: 1.0
    Content-Type: multipart/mixed; boundary="BOUNDARY"

    --BOUNDARY
    Content-Type: application/node.eks.aws

    apiVersion: node.eks.aws/v1alpha1
    kind: NodeConfig
    spec:
      kubelet:
        config:
          maxPods: ${var.node_max_pods}

    --BOUNDARY--
  EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = merge(var.common_tags, {
      Name = "${var.project_name}-node"
    })
  }
}