resource "aws_dynamodb_table" "dynamodb_terraform_lock" {
  name           = var.dynamedb_name
  hash_key       = "LockID"
  read_capacity  = 1
  write_capacity = 1
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    Name = var.perfix
  }
}

#tfstate S3存储桶
resource "aws_s3_bucket" "s3_tfstate" {
  bucket = "${var.perfix}-tfstate-orjujeng"
  tags = {
    Name = "${var.perfix}-tfstate-orjujeng"
  }
}