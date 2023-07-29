resource "aws_sns_topic" "sg_sns_topic" {
  name = var.sns_topic_name
}

resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  for_each = toset(var.email_list)
  depends_on = [ aws_sns_topic.sg_sns_topic ]
  topic_arn = aws_sns_topic.sg_sns_topic.arn
  protocol  = "email"
  endpoint  = "${each.value}"
}
