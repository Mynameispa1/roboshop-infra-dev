variable "project_name" {
  default = "roboshop"
}
variable "environment" {
  default = "dev"
}

variable "common_tags" {
  default = {}
  type = map
}

variable "vpc_tags" {
  default = {}
  type = map
}