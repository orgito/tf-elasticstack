# Terraform config for Elastic Stack Infra

## Initial Setup

There are a few tasks you need to perform after cloning the repo to your local machine:

### Install Terraform

Terraform does not require installation. Just download the binary from https://www.terraform.io/ and copy it to a folder in your path. On Linux and Mac `/usr/local/bin` is a good place.

> **Attention:** Make sure to download the latest 0.11.x release. Terraform 0.12, when available, will be a different language and will require an [Upgrade processs](https://www.terraform.io/upgrade-guides/0-12.html).

Verify your installation before proceeding:
```
$ terraform version
Terraform v0.11.11
```

### Initialization

The first command to run for a new configuration -- or after checking out an existing configuration from version control -- is `terraform init`, which initializes various local settings and data that will be used by subsequent commands.

```
$ terraform init
Initializing modules...
...
```

### Multiple Environments (prod, dev, etc)

The config is prepared to work with multiple environments. There is validation in place to make sure you don't accidentally deploy the wrong config to the wrong environment (dev to production for example). The validation is simple. It will check that your `stage` variable has the same value as your current workspace. If that is not the case it will fail to continue.

Before continuing create the environments you want to use:
$ terraform workspace new prod
Created and switched to workspace "prod"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.

```
$ terraform workspace new prod
Created and switched to workspace "prod"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.

$ terraform workspace new dev
Created and switched to workspace "dev"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.
```

To show the current environment use the subcommand `show`:

```
$ terraform workspace show
dev
```

To change the environment use the subcommand `select`

```
$ terraform workspace select prod
Switched to workspace "prod".
```

Here is what happens if you try to deploy to the wrong environment:

```
$ terraform apply

Error: module.alb.null_resource.validate_worspace: : invalid or unknown key:
ERROR: You are trying to run dev stage in the prod workspace.
Create/Select the correct workspace first.

Error: module.elasticsearch.module.cluster.null_resource.validate_worspace: : invalid or unknown key:
ERROR: You are trying to run dev stage in the prod workspace.
Create/Select the correct workspace first.

Error: module.kibana.module.cluster.null_resource.validate_worspace: : invalid or unknown key:
ERROR: You are trying to run dev stage in the prod workspace.
Create/Select the correct workspace first.

Error: module.logstash.module.cluster.null_resource.validate_worspace: : invalid or unknown key:
ERROR: You are trying to run dev stage in the prod workspace.
Create/Select the correct workspace first.

Error: null_resource.validate_worspace: : invalid or unknown key:
ERROR: You are trying to run dev stage in the prod workspace.
Create/Select the correct workspace first.
```

## Configuration

There are many ways to pass paramenters to terraform. The more convenient is through files. That repo contains to sample files that we can use. Copy `dev.tfvars.sample` and `prod.tfvars.sample` to `dev.tfvars` and `prod.tfvars` and adjust the parameters. The included values are reasonable defaults.

Here is the list of variables with the description:

Variable | Description | Default
-------- | ----------- | -------
aws_access_key | The AWS Access of the account used to deploy the infra. I suggest creating a dedicated user with only programatic acess.
aws_secret_key | The AWS secret key
region | AWS region
vpc | VPC ID where to deploy the instances. *Has to be in the selected region.*
subnets |  At least 2 subnets are required or the load balances will fail to be provisioned. Each subnet should be on a different availability zone. *Has to be in the selected vpc.*
stage | The Stage or Environment you are deploying, e.g. `prod`, `staging`, `dev`, `qa`
namespace | Namespace, which could be your organization name or abbreviation, e.g. `co` or `company`
cluster_name | Elasticsearch Cluster Name. Will be concatenated with namespace and prefix to set Elasticsearch `cluster.name` variable
ssh_key_pair | SSH key pair name that will be added to the instances. https://console.aws.amazon.com/ec2/v2/home?#KeyPairs
elk_version | Elastic Stack version to install (6.X.Y) during the initial provisioning. If blank or `latest` will install the latest version. | latest
**es_instance_type** | Elasticsearch Node instance type
es_node_count | Number of Elasticsearch Nodes in the cluster | 4
es_storage_size | Elasticsearch Node data volume size (GB) | 100
**kibana_instance_type** | Kibana instance type
kibana_node_count | Number of Kibana Nodes in the cluster | 2
**logstash_instance_type** | Logstash instance type
logstash_node_count | Number of Logstash Nodes in the cluster | 2
**cerebro_instance_type** | Cerebro instance type | t3.small
cerebro_version | Cerebro version to provision (tested with 0.8.1) | 0.8.1

> ***_instance_type**: Make sure that the instace types selected are available in the selected region.

### Logstash Pipeline Configuration

Terraform will deploy the file `files/logstash.conf` as the initial Logstash pipeline. You can customize it to your needs, but remember to keep the `hosts` attributte of the `elasticsearch` output like in the file if you want it to use the provisioned elasticsearch cluster.

```ruby
output {
  elasticsearch {
    hosts => ['${elasticsearch_lb_host}']
    ...
  }
}
```

Terraform will replace the string `${elasticsearch_lb_host}` with the correct value.

## Deployment

After adjusting the variables, make sure that you are in the appropriate environment and deploy the infrastructure:

```
$ terraform workspace select dev
Switched to workspace "dev".

$ terraform apply --var-file=dev.tfvars
...
```

Terraform will show you a summary of the changes and ask for confirmation. Carefully review the changes and, if you agree type `yes` and enter to apply the changes.

After deploying the infrastructure Terraform will show you a set of usefuls output.

### Default var-file

If you rather not specify the filename every time, simply rename you most used file to terraform.tfvars. Terraform you automatically load that file if it exists. Files explicitly passed with `--var-file` will have precedence.

### Destroying

If you are done with a test environment and wants to clean everything up use the `destroy` command:

```
$ terraform destroy --var-file=dev.tfvars
```

Terraform will show you the summary and ask for confirmation before continuing.
