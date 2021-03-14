variable "region" {
    type =  string
}

variable "az" {
  type = list(string)
}


variable "vpc" {
  type =  string
}

variable "ami" {
    type = string
  
}

variable "private_cidr" {
    type =  list(string)
  
}

variable "public_cidr" {
    type =  list(string)
  
}

variable "public_az" {
    type = list(string)
  
}

variable "private_az" {
    type = list(string)
  
}
 
variable "subnet_name_public" {
    type = list(string)
  
}

variable "subnet_name_private" {
    type = list(string)
  
}