variable "common_tags" {
  default = {
    Project     = "roboshop"
    Environment = "dev"
    Terraform   = "true"
  }
}

variable "tags" {
  default = {
    Component = "user"
  }
}
variable "project_name" {
  default = "roboshop"
}

variable "environment" {
  default = "dev"
}

variable "zone_id" {
  type = string
  default = "Z1024693OKJAW10DDB2X"
}

variable "zone_name" {
  type = string
  default = "pavankumarmuvva.online"
}

variable "iam_instance_profile" {
  default = "ShellScriptRoleForRoboshop"
}