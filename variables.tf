variable "environment" {
  type    = string
}

variable "prefix" {
  type    = string
  default = "specialised"
}

variable "cidr_block" {
  type    = string
  default = "10.10.0.0/16"
}

variable "public_subnets" {
  type    = number
  default = 1
}

variable "create_private_subnets" {
  type    = bool
  default = true
}

variable "private_subnets" {
  type    = number
  default = 1
}

variable "private_subnets_newbits" {
  type    = number
  default = 128
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "instance_key" {
  type    = string
  default = "miguelstudying-dev-kp"
}

variable "billing_code" {
  type        = string
  description = "(Required) Billing code for resources"
}