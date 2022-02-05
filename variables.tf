variable "ami_id" {
  default = "ami-03fa4afc89e4a8a09"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "project_cidr" {
  default = "172.30.0.0/16"
}

variable "cidr_bits" {
  default = 3
}

variable "project_name" {
  default = "metanet"
}

variable "project_env" {
  default = "dev"
}

variable "project_owner" {
  default = "fuji"
}

variable "volume-size" {
  default = 10
}