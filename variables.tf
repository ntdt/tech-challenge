variable "namespace" {
  type    = string
  default = null
}

variable "region" {
  type    = string
  default = null
}

variable "vpc_cidr" {
  type        = string
  description = "i.e.: 10.0.0.0/16"
  default     = null
}

variable "worker_count" {
  type        = number
  description = "Number of workers"
}
