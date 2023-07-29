locals {
  filter_metrics_type = {
    "security_group_change" = {
      metric_description         = "Secuity group update alert",
      pattern                    = "{($.eventName=AuthorizeSecurityGroupIngress)||($.eventName=AuthorizeSecurityGroupEgress)||($.eventName=RevokeSecurityGroupIngress)||($.eventName=RevokeSecurityGroupEgress)||($.eventName=CreateSecurityGroup)||($.eventName=DeleteSecurityGroup)}",
      metric_transformation_name = "SecurityGroupEventCount"
    },
    "user_creation_or_deletion" = {
      metric_description         = "User creation or deletion alert",
      pattern                    = "{($.eventName=CreateUser)||($.eventName=DeleteUser)}",
      metric_transformation_name = "UserCreationOrDeletionEvent"
    },
    "console_login_failed" = {
      metric_description         = "Console login failed alert",
      pattern                    = "{($.eventName=ConsoleLogin)&&($.errorMessage=\"Failed authentication\")}",
      metric_transformation_name = "ConsoleLoginFailedEvent"
    },
    "iam_group_policy_change" = {
      metric_description         = "IAM Group policy update alert",
      pattern                    = "{ ($.eventName=DeleteGroupPolicy)||($.eventName=PutGroupPolicy)||($.eventName=AttachGroupPolicy)||($.eventName=DetachGroupPolicy) }",
      metric_transformation_name = "IAMGroupPolicyChange"
    },
    "iam_role_policy_change" = {
      metric_description         = "IAM Role policy update alert",
      pattern                    = "{($.eventName=DeleteRolePolicy)||($.eventName=PutRolePolicy)||($.eventName=AttachRolePolicy)||($.eventName=DetachRolePolicy)}",
      metric_transformation_name = "IAMRolePolicyChange"
    },
    "iam_user_policy_change" = {
      metric_description         = "IAM User policy update alert",
      pattern                    = "{($.eventName=DeleteUserPolicy)||($.eventName=PutUserPolicy)||($.eventName=AttachUserPolicy)||($.eventName=DetachUserPolicy)}",
      metric_transformation_name = "IAMUserPolicyChange"
    },
    "iam_policy_change" = {
      metric_description         = "IAM policy update alert",
      pattern                    = "{($.eventName=CreatePolicy)||($.eventName=DeletePolicy)||($.eventName=CreatePolicyVersion)||($.eventName=DeletePolicyVersion)}",
      metric_transformation_name = "IAMPolicyChange"
    },
    "iam_user_added_to_group" = {
      metric_description         = "IAM user is added to a group alert",
      pattern                    = "{($.eventName=AddUserToGroup)}",
      metric_transformation_name = "IAMUserAddedToGroup"
    },
    "role_creation_or_deletion" = {
      metric_description         = "IAM role creation or deletion alert",
      pattern                    = "{($.eventName=CreateRole)||($.eventName=DeleteRole)}",
      metric_transformation_name = "IAMRoleCreationOrDeletionEvent"
    }
    
  }
}

resource "aws_cloudwatch_log_metric_filter" "management_activities_filter" {
  for_each       = local.filter_metrics_type
  name           = each.key
  pattern        = each.value.pattern
  log_group_name = aws_cloudwatch_log_group.cloudtrail_event_logs.name

  metric_transformation {
    name      = each.value.metric_transformation_name
    namespace = var.metric_namespace
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "management_activities_alarm" {
  for_each            = local.filter_metrics_type
  depends_on          = [aws_sns_topic.sg_sns_topic]
  alarm_name          = "${each.key}_alarm"
  metric_name         = each.value.metric_transformation_name
  threshold           = "1"
  statistic           = "Average"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = "1"
  evaluation_periods  = "1"
  period              = "60"
  namespace           = var.metric_namespace
  alarm_actions       = [aws_sns_topic.sg_sns_topic.arn]
  alarm_description   = each.value.metric_description
}
