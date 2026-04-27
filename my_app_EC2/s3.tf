resource "aws_s3_bucket" "images" {
  bucket = "zzw-myapp-images-123456"  # ⚠️ 改成唯一
}

resource "aws_s3_bucket_public_access_block" "images" {
  bucket = aws_s3_bucket.images.id

  block_public_acls   = false
  block_public_policy = false
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.images.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = "*"
      Action = ["s3:GetObject"]
      Resource = "${aws_s3_bucket.images.arn}/*"
    }]
  })
}