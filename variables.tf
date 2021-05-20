variable "ami_value" {
  description = "Value of the AMI to be used"
  type        = string
  default     = "ami-03d5c68bab01f3496"
}

variable "instance_type" {
  description = "Instance type to be used"
  type        = string
  default     = "t2.micro"
}

variable "ssh_port" {
  description = "The initial port the EC2 Instance should listen on for SSH requests."
  type        = number
  default     = 22
}

variable "ssh_user" {
  description = "The user you connect as when attempting an SSH connection."
  type        = string
  default     = "ubuntu"
}
