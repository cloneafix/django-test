# django-test

The main Idea to deploy the django test application on AWS is:
- Dockerize the code with their dependencies
	- see: cfn/infrastructure-stack-config.yaml
- Build, Run and Deploy all code changes with a CI/CD Pipeline
	- see: buildspec.yaml
- Run the dockerized appliction on an AWS ECS cluster

To try this out: fork this repo and follow the instructions below.

# Deployment & Setup

## Infrastructure

This will setup the needed AWS services to run the app.

### Requirements
* AWS CLI already configured with Administrator access
    - Alternatively, you can use a [Cloudformation Service Role with Admin access](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-iam-servicerole.html)
* cfn-sphere to simplify cloudformation stack deployment, best to use with python2
```
pip install cfn-sphere
```

### Install
You need to setup your AWS credentials in your shells environment. Like:
```
export AWS_ACCESS_KEY_ID=xxxxxxxxxxxxxx
export AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxx
export AWS_DEFAULT_REGION=eu-central-1
```
Now you are ready to deploy the infrastructure with cloudformation:
```
cf sync cfn/infrastructure-stack-config.yaml
```

## Pipeline

### Requirements

* AWS CLI already configured with Administrator access
    - Alternatively, you can use a [Cloudformation Service Role with Admin access](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-iam-servicerole.html)
* [Github Personal Token](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/) with full permissions on **admin:repo_hook and repo**

### Configuring GitHub Integration

This Pipeline is configured to look up for GitHub information stored on [EC2 System Manager Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-paramstore.html) such as Branch, Repo, Username and OAuth Token.

Replace the placeholders with values corresponding to your GitHub Repo and Token:

```bash
aws ssm put-parameter \
    --name "/service/fbo/github/repo" \
    --description "Github Repository name for Cloudformation Stack fbo-pipeline" \
    --type "String" \
    --value "GITHUB_REPO_NAME"

aws ssm put-parameter \
    --name "/service/fbo/github/token" \
    --description "Github Token for Cloudformation Stack fbo-pipeline" \
    --type "String" \
    --value "TOKEN"

aws ssm put-parameter \
    --name "/service/fbo/github/user" \
    --description "Github Username for Cloudformation Stack fbo-pipeline" \
    --type "String" \
    --value "GITHUB_USER"
```

**NOTE:** Keep in mind that these Parameters will only be available within the same region you're deploying this Pipeline stack. Also, if these values ever change you will need to [update these parameters](https://docs.aws.amazon.com/cli/latest/reference/ssm/put-parameter.html) as well as update the "fbo-pipeline" Cloudformation stack.

### Pipeline creation

Run the following AWS CLI command to create the pipeline:

```bash
aws cloudformation create-stack \
    --stack-name fbo-pipeline \
    --template-body file://cfn/templates/pipeline.yaml \
    --capabilities CAPABILITY_NAMED_IAM
```
or with cfn-sphere:
```
cf sync cfn/pipeline-stack-config.yaml
```

### Release through the newly built Pipeline

> **Build steps**

This Pipeline expects `buildspec.yaml` to be at the root of this `git repository` and **CodeBuild** expects will read and execute all sections during the Build stage.
