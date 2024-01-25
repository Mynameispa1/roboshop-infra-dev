# 1.Create target group
#     a) Add health check block while creating the target group
# 2. In the process of autoscalling. 
    # a)Create one instance
    # b)provision the instnace using the ansible
    # c)stop the instnace.
    # d)take the Ami
    # e)Delete the instance
    # f)Now, finally create launch template

#Creating a target group
resource "aws_lb_target_group" "test" {
  name     = "${local.name}-${var.tags.Component}"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_ssm_parameter.vpc_id.value
  
  health_check {  #This is health check for the target group
    path = "/health"
    port = 8080
    healthy_threshold = 2
    unhealthy_threshold = 3
    timeout = 5
    interval = 10
    matcher = "200-299"  # has to be HTTP 200 or fails
  }
}

#creating instance
module "catalogue" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  ami = data.aws_ami.centos.id
  name                   = "${local.name}-${var.tags.Component}-ami"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.catalogue_sg_id.value]
  subnet_id              = element(split(",", data.aws_ssm_parameter.private_subnet_ids.value), 0)
  tags = merge(
    var.common_tags,
    var.tags
  )
}

#provisioning the instnace using the ansible

resource "null_resource" "catalogue" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    instance_id = module.catalogue.id
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    host = module.catalogue.private_ip
    type = "ssh"
    user = "centos"
    password = "DevOps321"
  }

  provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh catalogue dev"
    ]
  }
}

#Stopping the instance which is created 
resource "aws_ec2_instance_state" "catalogue" {
  instance_id = module.catalogue.id
  state       = "stopped"
  depends_on = [ null_resource.catalogue ] #we need to mention depends_on becuase it will be stopped during the provisioning itself
}

#Taking Ami from the instance
resource "aws_ami_from_instance" "catalogue" {
  name               = "${local.name}-${var.tags.Component}-${local.current_time}"
  source_instance_id = module.catalogue.id
}

#Deleting the instance which we created.
resource "null_resource" "catalogue_delete" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    instance_id = module.catalogue.id
  }

  provisioner "local-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    command = "aws ec2 terminate-instances --instance-ids ${module.catalogue.id}"
  }

  depends_on = [ aws_ami_from_instance.catalogue]
}

#Creating Launch Templates
resource "aws_launch_template" "catalogue" {
  name = "${local.name}-${var.tags.Component}"
  image_id = aws_ami_from_instance.catalogue.id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t2.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.catalogue_sg_id.value]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${local.name}-${var.tags.Component}"
    }
  }
}





