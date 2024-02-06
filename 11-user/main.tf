module "user" {
  source = "../../terraform-roboshop-app"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  component_sg_id = data.aws_ssm_parameter.user_sg_id.value
  private_subnet_ids =split(",", data.aws_ssm_parameter.private_subnet_ids.value)
  iam_instance_profile = "ShellScriptRoleForRoboshop"
  project_name = var.project_name
  environment = var.environment
  tags = var.tags
  common_tags =  var.common_tags 
  zone_name = var.zone_name
  zone_id = var.zone_id
}