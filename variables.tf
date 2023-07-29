variable "awsRegion" {
  type = string
  default = "us-east-1"
}

variable "cloudtrail_role_name" {
  type = string
  default = "cloudtrail_to_cloudwatch"
}

variable "cloudtrail_role_policy_name" {
  type = string
  default = "cloudtrail_to_cloudwatch_policy"
}

variable "log_group_name" {
  type = string
  default = "cloudtrail_to_cloudwatch_logs"
}

variable "trail_name" {
  type = string
  default = "monitor_account_activities"
}

variable "trail_bucket_name" {
  type = string
  default = "cloudtrail-monitor-management-event-logs"
}

variable "metric_namespace" {
  type = string
  default = "management_activities"
}

variable "sns_topic_name" {
  type = string
  default = "management-updates"
}

variable "email_list" {
  type = list(string)
  description = "List of emails who will receive the notification based on cloudwatch alarm"
  default = ["test@test.com"]
}