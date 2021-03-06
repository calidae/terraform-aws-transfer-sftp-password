provider "aws" {}

module "sftp" {
    source = "calidae/transfer-sftp-password/aws"
}

output "sftp_endpoint" {
  value       = module.sftp.endpoint
  description = "SFTP endpoint"
}

output "sftp_password" {
  value       = module.sftp.password
  description = "Run `terraform output sftp_password`"
  sensitive   = true
}

output "s3_bucket_name" {
  value       = module.sftp.bucket_name
  description = "S3 name"
}
