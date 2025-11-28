resource "aws_security_group" "node_group_remote_access" {
  name        = "node-group-ssh"
  description = "Allow SSH to worker nodes"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "port 22 allow"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  egress {
    description = "allow all outgoing traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"
  cluster_name    = "fullstack_chatapp"
  cluster_version = "1.31"

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true


  access_entries = {
  main-user = {
    principal_arn = "arn:aws:iam::661596277003:user/MainUser"
    policy_associations = {
      admin = {
        policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
        access_scope = {
          type = "cluster"
        }
      }
    }
  }
}



  cluster_security_group_additional_rules = {
    kubectl_from_my_ip = {
      source_security_group_id = aws_security_group.sg.id
      description = "Allow HTTPS from my IP for kubectl"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      type        = "ingress"
    }
  }


  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }


  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets


  eks_managed_node_group_defaults = {
    instance_types                         = ["t3.large"]
    attach_cluster_primary_security_group  = true
  }


  eks_managed_node_groups = {
    tws-demo-ng = {
      min_size     = 1
      max_size     = 3
      desired_size = 1

      instance_types = ["t3.large"]
      capacity_type  = "SPOT"

      disk_size                  = 35
      use_custom_launch_template = false

      remote_access = {
        ec2_ssh_key               = aws_key_pair.key_pair.key_name
        source_security_group_ids = [aws_security_group.node_group_remote_access.id]
      }

      tags = {
        Name        = "Eks-node-group"
        Environment = "prod"
        ExtraTag    = "chat-app"
      }
    }
  }

  tags = {
    Name        = "Eks Cluster"
    Environment = "prod"
  }
}


data "aws_instances" "eks_nodes" {
  instance_tags = {
    "eks:cluster-name" = module.eks.cluster_name
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }

  depends_on = [module.eks]
}
