// Global variables
variable "region" {}
variable "environment" {}
variable "tags" {
    type = map
}
variable "db_username" {
  default     = "admin"
}
variable "db_password" {}
variable "db_instance_type" {}
variable "db_name" {}

