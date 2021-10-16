resource "aws_iam_role" "codebuild-ecs-deploy-flask-example" {
  name = "codebuild-ecs-deploy-flask-example"

  assume_role_policy = <<-EOS
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "codebuild.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOS
  path               = "/service-role/"
}

resource "aws_iam_role_policy" "codebuild-ecs-deploy-flask-example" {
  name = "codebuild-ecs-deploy-flask-example"
  role = aws_iam_role.codebuild-ecs-deploy-flask-example.id

  policy = <<-EOS
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Resource": [
          "arn:aws:logs:ap-northeast-1:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/*"
        ],
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "codebuild:CreateReportGroup",
          "codebuild:CreateReport",
          "codebuild:UpdateReport",
          "codebuild:BatchPutTestCases",
          "codebuild:BatchPutCodeCoverages"
        ],
        "Resource": [
          "arn:aws:codebuild:ap-northeast-1:${data.aws_caller_identity.current.account_id}:report-group/*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation",
          "iam:PassRole",
          "ecs:*",
          "ecr:*",
          "ssm:GetParameters"
        ],
        "Resource": "*"
      }
    ]
  }
  EOS
}

resource "aws_codebuild_project" "ecs-deploy-flask-example-build" {
  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    modes = ["LOCAL_DOCKER_LAYER_CACHE"]
    type  = "LOCAL"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    privileged_mode = "true"
    type            = "LINUX_CONTAINER"
  }

  name         = "ecs-deploy-flask-example-build"
  service_role = aws_iam_role.codebuild-ecs-deploy-flask-example.arn

  source {
    git_clone_depth = "1"

    git_submodules_config {
      fetch_submodules = "false"
    }

    location = "https://github.com/hi1280/ecs-deploy-flask-example.git"
    type     = "GITHUB"
  }
}

resource "aws_codebuild_project" "ecs-deploy-flask-example-deploy" {
  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "${data.aws_caller_identity.current.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/ecspresso:v1.6.2"
    image_pull_credentials_type = "SERVICE_ROLE"
    type                        = "LINUX_CONTAINER"
  }

  name         = "ecs-deploy-flask-example-deploy"
  service_role = aws_iam_role.codebuild-ecs-deploy-flask-example.arn

  source {
    buildspec       = "deployspec.yml"
    git_clone_depth = "1"

    git_submodules_config {
      fetch_submodules = "false"
    }

    location = "https://github.com/hi1280/ecs-deploy-flask-example.git"
    type     = "GITHUB"
  }
}

resource "aws_iam_role" "codepipeline-ecs-deploy-flask-example" {
  name = "codepipeline-ecs-deploy-flask-example"

  assume_role_policy = <<-EOS
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "codepipeline.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOS
  path               = "/service-role/"
}

resource "aws_iam_role_policy" "codepipeline-ecs-deploy-flask-example" {
  name = "codepipeline-ecs-deploy-flask-example"
  role = aws_iam_role.codepipeline-ecs-deploy-flask-example.id

  policy = <<-EOS
  {
      "Statement": [
          {
              "Action": [
                  "iam:PassRole"
              ],
              "Resource": "*",
              "Effect": "Allow",
              "Condition": {
                  "StringEqualsIfExists": {
                      "iam:PassedToService": [
                          "cloudformation.amazonaws.com",
                          "elasticbeanstalk.amazonaws.com",
                          "ec2.amazonaws.com",
                          "ecs-tasks.amazonaws.com"
                      ]
                  }
              }
          },
          {
              "Action": [
                  "codecommit:CancelUploadArchive",
                  "codecommit:GetBranch",
                  "codecommit:GetCommit",
                  "codecommit:GetRepository",
                  "codecommit:GetUploadArchiveStatus",
                  "codecommit:UploadArchive"
              ],
              "Resource": "*",
              "Effect": "Allow"
          },
          {
              "Action": [
                  "codedeploy:CreateDeployment",
                  "codedeploy:GetApplication",
                  "codedeploy:GetApplicationRevision",
                  "codedeploy:GetDeployment",
                  "codedeploy:GetDeploymentConfig",
                  "codedeploy:RegisterApplicationRevision"
              ],
              "Resource": "*",
              "Effect": "Allow"
          },
          {
              "Action": [
                  "codestar-connections:UseConnection"
              ],
              "Resource": "*",
              "Effect": "Allow"
          },
          {
              "Action": [
                  "elasticbeanstalk:*",
                  "ec2:*",
                  "elasticloadbalancing:*",
                  "autoscaling:*",
                  "cloudwatch:*",
                  "s3:*",
                  "sns:*",
                  "cloudformation:*",
                  "rds:*",
                  "sqs:*",
                  "ecs:*"
              ],
              "Resource": "*",
              "Effect": "Allow"
          },
          {
              "Action": [
                  "lambda:InvokeFunction",
                  "lambda:ListFunctions"
              ],
              "Resource": "*",
              "Effect": "Allow"
          },
          {
              "Action": [
                  "opsworks:CreateDeployment",
                  "opsworks:DescribeApps",
                  "opsworks:DescribeCommands",
                  "opsworks:DescribeDeployments",
                  "opsworks:DescribeInstances",
                  "opsworks:DescribeStacks",
                  "opsworks:UpdateApp",
                  "opsworks:UpdateStack"
              ],
              "Resource": "*",
              "Effect": "Allow"
          },
          {
              "Action": [
                  "cloudformation:CreateStack",
                  "cloudformation:DeleteStack",
                  "cloudformation:DescribeStacks",
                  "cloudformation:UpdateStack",
                  "cloudformation:CreateChangeSet",
                  "cloudformation:DeleteChangeSet",
                  "cloudformation:DescribeChangeSet",
                  "cloudformation:ExecuteChangeSet",
                  "cloudformation:SetStackPolicy",
                  "cloudformation:ValidateTemplate"
              ],
              "Resource": "*",
              "Effect": "Allow"
          },
          {
              "Action": [
                  "codebuild:BatchGetBuilds",
                  "codebuild:StartBuild",
                  "codebuild:BatchGetBuildBatches",
                  "codebuild:StartBuildBatch"
              ],
              "Resource": "*",
              "Effect": "Allow"
          },
          {
              "Effect": "Allow",
              "Action": [
                  "devicefarm:ListProjects",
                  "devicefarm:ListDevicePools",
                  "devicefarm:GetRun",
                  "devicefarm:GetUpload",
                  "devicefarm:CreateUpload",
                  "devicefarm:ScheduleRun"
              ],
              "Resource": "*"
          },
          {
              "Effect": "Allow",
              "Action": [
                  "servicecatalog:ListProvisioningArtifacts",
                  "servicecatalog:CreateProvisioningArtifact",
                  "servicecatalog:DescribeProvisioningArtifact",
                  "servicecatalog:DeleteProvisioningArtifact",
                  "servicecatalog:UpdateProduct"
              ],
              "Resource": "*"
          },
          {
              "Effect": "Allow",
              "Action": [
                  "cloudformation:ValidateTemplate"
              ],
              "Resource": "*"
          },
          {
              "Effect": "Allow",
              "Action": [
                  "ecr:DescribeImages"
              ],
              "Resource": "*"
          },
          {
              "Effect": "Allow",
              "Action": [
                  "states:DescribeExecution",
                  "states:DescribeStateMachine",
                  "states:StartExecution"
              ],
              "Resource": "*"
          },
          {
              "Effect": "Allow",
              "Action": [
                  "appconfig:StartDeployment",
                  "appconfig:StopDeployment",
                  "appconfig:GetDeployment"
              ],
              "Resource": "*"
          }
      ],
      "Version": "2012-10-17"
  }
  EOS
}

resource "aws_codepipeline" "ecs-deploy-flask-example" {
  artifact_store {
    location = "codepipeline-ap-northeast-1-204500680427"
    type     = "S3"
  }

  name     = "ecs-deploy-flask-example"
  role_arn = aws_iam_role.codepipeline-ecs-deploy-flask-example.arn

  stage {
    action {
      category = "Source"

      configuration = {
        BranchName           = "master"
        ConnectionArn        = "arn:aws:codestar-connections:ap-northeast-1:${data.aws_caller_identity.current.account_id}:connection/68e4fdfd-28bd-4598-b134-81a06746021e"
        DetectChanges        = "false"
        FullRepositoryId     = "hi1280/ecs-deploy-flask-example"
        OutputArtifactFormat = "CODE_ZIP"
      }

      name             = "Source"
      namespace        = "SourceVariables"
      output_artifacts = ["SourceArtifact"]
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      region           = "ap-northeast-1"
      run_order        = "1"
      version          = "1"
    }

    name = "Source"
  }

  stage {
    action {
      category = "Build"

      configuration = {
        BatchEnabled = "false"
        ProjectName  = aws_codebuild_project.ecs-deploy-flask-example-build.name
      }

      input_artifacts  = ["SourceArtifact"]
      name             = "Build"
      namespace        = "BuildVariables"
      output_artifacts = ["BuildArtifact"]
      owner            = "AWS"
      provider         = "CodeBuild"
      region           = "ap-northeast-1"
      run_order        = "1"
      version          = "1"
    }

    name = "Build"
  }

  stage {
    action {
      category = "Build"

      configuration = {
        EnvironmentVariables = "[{\"name\":\"IMAGE_TAG\",\"value\":\"#{BuildVariables.IMAGE_TAG}\",\"type\":\"PLAINTEXT\"},{\"name\":\"ENV\",\"value\":\"staging\",\"type\":\"PLAINTEXT\"}]"
        ProjectName          = aws_codebuild_project.ecs-deploy-flask-example-deploy.name
      }

      input_artifacts = ["SourceArtifact"]
      name            = "staging"
      owner           = "AWS"
      provider        = "CodeBuild"
      region          = "ap-northeast-1"
      run_order       = "1"
      version         = "1"
    }

    action {
      category  = "Approval"
      name      = "approve"
      owner     = "AWS"
      provider  = "Manual"
      region    = "ap-northeast-1"
      run_order = "2"
      version   = "1"
    }

    action {
      category = "Build"

      configuration = {
        EnvironmentVariables = "[{\"name\":\"IMAGE_TAG\",\"value\":\"#{BuildVariables.IMAGE_TAG}\",\"type\":\"PLAINTEXT\"},{\"name\":\"ENV\",\"value\":\"production\",\"type\":\"PLAINTEXT\"}]"
        ProjectName          = aws_codebuild_project.ecs-deploy-flask-example-deploy.name
      }

      input_artifacts = ["SourceArtifact"]
      name            = "production"
      owner           = "AWS"
      provider        = "CodeBuild"
      region          = "ap-northeast-1"
      run_order       = "3"
      version         = "1"
    }

    name = "Deploy"
  }
}