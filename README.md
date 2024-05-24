# myapp-terraform

This project is an entire Infrastructure and CI/CD setup for a typeorm-express-typescript application
like [this one](!https://github.com/WilliamAvila/typeorm-express-typescript) 

Requirements

- Terraform 
- AWS CLI

 Workspaces

- create a new workspace `terraform workspace new ENV` it can be dev, stage, prod, etc.
- `terraform workspace select ENV`



Env Variables Setup

 - To deploy fill all the variables in the `locals.tf` and `variables.tf` files

To set up terraform backend you will need to provide the `s3_bucket_backend` and `dynamodb_backend` variables

Running

- `tf init`
- `tf plan`
- `tf apply`



Compenents used:

- ECS, RDS PostgreSQL, S3, VPC, Codebuild, Codepipline, Cloudwatch, etc.


Infrastructure diagram
![Infrastructure](assets/infra.png)

CI/CD pipeline diagram
![CI/CD](assets/ci-cd-pipeline.png)

Monitoring and logging
- Cloudwatch 
- Cloudwatch Logs

For Monitoring there's CloudWatchs logs configured for Codebuild ECS task and a Cloudwatch Dashboard to Monitor the ECS service CPU and Memory usage


Autoscaling
- ECS Service AutoScaling

There are Cloudwatch alarms configured that trigger the autoscaling policies when there's high resource consumption

