variable "vpc_cidr" {
  default = "192.168.0.0/23"
}

variable "tenancy" {
    default = "dedicated"
  
}

variable "vpc_id" {}


variable "public_cidr" {
  
  type =  list(string)
  
  default = ["192.167.0.0/28" ,"192.167.0.16/28"]
  
}

variable "private_cidr" {
  
  type =  list(string)
  
  default = ["192.167.1.0/28" ,"192.167.1.16/28"]
  
}

variable "public_az" {
  type = list(string)

  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  
}

variable "private_az" {
  type = list(string)

  default = ["eu-west-1a", "eu-west-1b","eu-west-1c"]

}

variable "public_cidr_name" {

  type = list(string)

  default = ["Public01", "Public02", "Public03"]
  
}

variable "private_cidr_name" {

  type = list(string)

  default = ["Private01", "Private02", "Private03"]
  
}

variable "igw_id" {}

variable "subnet_id" {}

variable "route_table_id" {}

variable "security_groups_id" {}