region="us-east-1"
environment="dev"
app_key_name="etopia_dev_key"
app_instance_type="t2.micro"
rds_db_client_sg="sg-09aad486c0f3a1b74"
app_sg="sg-0fdd73ddb429fb499"
private_subnets=["subnet-009eeb215b2751157","subnet-018b0e3c69d2f9c4c"]
app_instances_count="2"
app_instance_max="4"
app_alb_target_group="etopia-dev-e80"
tags={
    owner = "Anant Vardhan"
    cost_center = "Etopia-Fonetwish"
    environment = "Dev"
    project = "Promotion Assessment"
}
