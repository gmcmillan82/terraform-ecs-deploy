variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "container_port" {
  type    = number
  default = 5000
}

variable "lb_port" {
  type    = number
  default = 80
}
