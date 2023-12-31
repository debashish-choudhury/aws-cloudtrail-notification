# AWS Cloudtrail Notification


## Description

**AWS Cloudtrail Notification** is an open source IaC written in **Terraform**. It helps in provisioning infrastucture in **AWS**, allows faculty to get notification if there is any change in AWS Account specified. User will get email notification, information triggered as per the alarms we set in **Cloudwatch** which inturn is based on the logs created by Cloudtrail in AWS Account. **AWS Cloudtrail** is a service which provides visibility into user activity by recording actions taken on your account. In this case we send a email notification to the user when the cloudwatch alarm gets triggered based on the logs generated by cloudtrail.


## Architecture

In this particular scenario, we will create a **Cloudwatch Logs**, which will collect all the API activities of users and store it in the Cloudwatch logs. Based on the cloudwatch logs, we will create **Metrics** and based in the Metrics, will create the **Alarms**.

Refer `main.tf` where we create trail role with assume role permissions and attach necessary policies to it, the CloudWatch Logs, **S3 Bucket** to store all the logs and create the Trail itself.

Refer `alarm.tf` to check how we create the metrics and alarms based on the metrics.

A user in a management account can create an organization trail that logs all events for all AWS accounts in that organization.

- To know more in **AWS Cloudtrail** Service: (https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-user-guide.html)


## Installation

#### Manual Installation

1. Download AWS CLI (latest Version)
2. Configure AWS in your machine by using command: `aws configure`
3. Download and install terraform ~1.4.6 or higher.
4. Clone the repository and check out the master branch: `git clone https://github.com/debashish-choudhury/aws-cloudtrail-notification.git`
5. Change directory the cloned repository: `cd aws-cloudtrail-notification`
6. Set credentials using the `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and optionally `AWS_SESSION_TOKEN` environment variables.
   ```
   % export AWS_ACCESS_KEY_ID="anaccesskey"
   % export AWS_SECRET_ACCESS_KEY="asecretkey"
   % export AWS_REGION="us-west-2"
   ```
7. Initialize the Terraform: `terraform init` \
   **Optional:**
   Want to use terraform backed? Uncomment the **terraform** block present in `providers.tf` and add bucket name, key and region as shown below: 
   ```
   terraform {
     backend "s3" {
       bucket = "mybucket"
       key    = "path/to/my/key"
       region = "us-east-1"
     }
   }
   ```
8. Run terraform plan: 
   ```bash
   terraform plan -out output.tfplan
   ```

   To get `JSON` output of terraform plan, run the following command:
   ```bash
   terraform show -no-color -json output.tfplan > output.json
   ```

**Important:** If working in team, you must enable state lock. It helps to lock the terraform state file when a member is updating the infra. Create a **Dynamodb Table** with the partition key ID as `LockID`.
Add the table name inside the backend block as show below:
```
terraform {
    backend "s3" {
    bucket         = "mybucket"
    key            = "path/to/my/key"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock-dynamo"
    }
}
```

**Important:** The Partition Key should be `LockID` or else the state lock will **not work** as expected.

**Important:** If you want to change the resource monitoring based on your requirements, please look at the below link which shows how we can modify the resource block `cloudtrail_event_logs` configuration present in `main.tf` **(event_selector)** section:
(https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail#event_selector)

**Important:** We need to create **Metric Filter Pattern** which will help create the alarm based on the Cloudwatch logs or else it won't be able to track resources changes. Hence, refer `alarm.tf`, how we create filter patterns and use those patterns to create alarms. Look at the local variable `filter_metrics_type`, resource name `aws_cloudwatch_log_metric_filter` how we create log metric filter and `aws_cloudwatch_metric_alarm` for creating alarms based on metrics.
(https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm)


## Configuration

### General

If you want to update your code to the latest version, use your terminal to go to the project aws-cloudtrail-notification `cd aws-cloudtrail-notification` and type the following command:

```bash
git pull
terraform init
terraform plan -out output.tfplan
terraform apply output.tfplan
```

If you changed nothing more than the config or the modules, this should work without any problems.
Type `git status` to see your changes, if there are any, you can reset them with `git reset --hard` After that, git pull should be possible.


## Contributing Guidelines

Contributions of all kinds are welcome, not only in the form of code but also with regards bug reports and documentation.

Please keep the following in mind:

- **Bug Reports**: Make sure you're running the latest version. If the issue(s) still persist: please open a clearly documented issue with a clear title.
- **Minor Bug Fixes**: Please send a pull request with a clear explanation of the issue or a link to the issue it solves.
- **Major Bug Fixes**: please discuss your approach in an GitHub issue before you start to alter a big part of the code.
- **New Features**: please please discuss in a GitHub issue before you start to alter a big part of the code. Without discussion upfront, the pull request will not be accepted / merged.

Thanks for your help in making AWS Cloudtrail notification!!!


## Important
This application in compatible to run in `Windows`, `Linux`, `OSX` .
To install all the dependencies required for this application run the following command: `terraform init` 

> ~ Debashish Choudhury



