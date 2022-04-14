
output "endpoint" {
  value       = aws_transfer_server.sftp.endpoint
  description = "SFTP endpoint"
}

output "password" {
  value       = random_password.sftp_password.result
  description = "SFTP master password"
  sensitive   = true
}

output "bucket_name" {
  value       = aws_s3_bucket.input.id
  description = "Input S3 name"
}
