# terraform-aws-transfer-sftp-password
Create a simple SFTP server with a master password.

The server uses a custom lambda function as the identity
provider, which will compare the password to the random password
value and yield a default authorization to a S3 bucket.

## Example

```
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
```
