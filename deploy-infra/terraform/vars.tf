variable "environment" {}
variable "app_key_name" {}
variable "app_instance_type" {}
variable "app_ami_id" {}
variable "rds_db_client_sg" {}
variable "app_sg" {}
variable "private_subnets" {}
variable "app_instances_count" {}
variable "app_instance_max" {}
variable "app_alb_target_group" {}
variable "tags" {type = default}
