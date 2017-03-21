This is sample lambda function written in Go with
github.com/eawsy/aws-lambda-go-core. This sends a
POST message to Slack whenever there's a Object
Delete event triggered by S3.


Usage:
=====

Start a docker-machine:

```bash
$ docker-machine create -d virtualbox aws-lambda
$ eval $(docker-machine env aws-lambda)
```

Build a zip file for lambda function:

```bash
$ cd build
$ make
```

Use Terraform to manage AWS resources:

```bash
$ cd terraform
$ terraform apply
$ terraform destroy
```
