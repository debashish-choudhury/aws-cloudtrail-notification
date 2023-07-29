resource "aws_iam_role" "cloudtrail_cloudwatch_role" {
  name = var.cloudtrail_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudtrail_role_policy" {
  name = var.cloudtrail_role_policy_name
  role = aws_iam_role.cloudtrail_cloudwatch_role.id

  # "arn:aws:logs:us-east-1:000000000000:log-group:${aws_cloudwatch_log_group.cloudtrail_event_logs.id}:*"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AWSCloudTrailCreateLogStream2014110",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream"
      ],
      "Resource": [
        "${aws_cloudwatch_log_group.cloudtrail_event_logs.arn}:*"
      ]
    },
    {
      "Sid": "AWSCloudTrailPutLogEvents20141101",
      "Effect": "Allow",
      "Action": [
        "logs:PutLogEvents"
      ],
      "Resource": [
        "${aws_cloudwatch_log_group.cloudtrail_event_logs.arn}:*"
      ]
    }
  ]
}
EOF
}

resource "aws_cloudwatch_log_group" "cloudtrail_event_logs" {
  name = var.log_group_name
}

resource "aws_cloudtrail" "event_logs" {
  depends_on = [ aws_s3_bucket_policy.cloudtrail_access_s3 ]
  name           = var.trail_name
  s3_bucket_name = aws_s3_bucket.cloudtrail_event_logs.id
  s3_key_prefix                 = ""
  include_global_service_events = true # Default is true
  is_multi_region_trail         = true # Default is false
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail_event_logs.arn}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_cloudwatch_role.arn

  # Exclude KMS and RDS event logs.
  event_selector {
    read_write_type                  = "All"
    include_management_events        = true
    exclude_management_event_sources = ["kms.amazonaws.com", "rdsdata.amazonaws.com"]
  }
}

resource "aws_s3_bucket" "cloudtrail_event_logs" {
  bucket        = var.trail_bucket_name
  force_destroy = true
}

data "aws_caller_identity" "current" {}

# Attach S3 bucket policy
resource "aws_s3_bucket_policy" "cloudtrail_access_s3" {
  bucket = aws_s3_bucket.cloudtrail_event_logs.id
  depends_on = [ aws_s3_bucket.cloudtrail_event_logs ]
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AWSCloudTrailAclCheck",
      "Effect": "Allow",
      "Principal": { "Service": "cloudtrail.amazonaws.com" },
      "Action": "s3:GetBucketAcl",
      "Resource": "${aws_s3_bucket.cloudtrail_event_logs.arn}"
    },
    {
      "Sid": "AWSCloudTrailWrite",
      "Effect": "Allow",
      "Principal": { "Service": "cloudtrail.amazonaws.com" },
      "Action": "s3:PutObject",
      "Resource": "${aws_s3_bucket.cloudtrail_event_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    }
  ]
}
POLICY
}
