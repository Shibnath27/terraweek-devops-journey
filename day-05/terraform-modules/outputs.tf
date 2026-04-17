output "web_server_public_ip" {
  description = "Public IP of web server"
  value       = module.web_server.public_ip
}

output "api_server_public_ip" {
  description = "Public IP of API server"
  value       = module.api_server.public_ip
}

output "security_group_id" {
  description = "Security Group ID"
  value       = module.web_sg.sg_id
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}
