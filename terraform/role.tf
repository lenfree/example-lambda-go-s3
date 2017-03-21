resource "aws_iam_policy" "iam_for_lambda_cloudwatch" {
  name        = "lambda-function-to-cloudwatch"
  description = "lambda to cloudwatch logs"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Action": [
        "logs:*"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:logs:ap-southeast-2:*:*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "iam_for_lambda_attach" {
  role       = "${aws_iam_role.iam_for_lambda.name}"
  policy_arn = "${aws_iam_policy.iam_for_lambda_cloudwatch.arn}"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "test_lambda" {
  filename      = "./../build/handler.zip"
  function_name = "s3_evt_slack"
  role          = "${aws_iam_role.iam_for_lambda.arn}"
  handler       = "handler.Handle"
  runtime       = "python2.7"

  environment {
    variables = {
      slack_api_token = "<change_me>"
    }
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket = "lenfree-lambda"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "${aws_s3_bucket.bucket.id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.test_lambda.arn}"
    events              = ["s3:ObjectCreated:*"]
  }

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.test_lambda.arn}"
    events              = ["s3:ObjectRemoved:*"]
  }
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.test_lambda.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.bucket.arn}"
}
