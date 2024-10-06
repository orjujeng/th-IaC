#后台java代码需要codebuild
#artifacts 的s3桶
resource "aws_s3_bucket" "application_artifacts_file" {
  bucket = "${var.perfix}-codebuild-artifacts-orjujeng"
  tags = {
    Name = "${var.perfix}-codebuild-artifacts-orjujeng"
  }
}

#作为codebuild输出文件的桶，必须开启版本控制。
resource "aws_s3_bucket_versioning" "application_artifacts_file_versioning_status" {
  bucket = aws_s3_bucket.application_artifacts_file.id
  versioning_configuration {
    status = "Enabled"
  }
}

#codebuild ec2 role:
resource "aws_iam_role" "applcation_ecc_codebuild_role" {
  name               = "${var.perfix}_ecc_codebuild_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_to_codebuild.json
}

#cloudwatch 权限
resource "aws_iam_role_policy_attachment" "applcation_ecc_codebuild_role_attach_CloudWatchFullAccess" {
  role       = aws_iam_role.applcation_ecc_codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}
#codepipeline 权限
resource "aws_iam_role_policy_attachment" "applcation_ecc_codebuild_role_attach_AWSCodePipeline_FullAccess" {
  role       = aws_iam_role.applcation_ecc_codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess"
}

#CodeBuildDeveloper 权限
resource "aws_iam_role_policy_attachment" "applcation_ecc_codebuild_role_attach_AWSCodeBuildDeveloperAccess" {
  role       = aws_iam_role.applcation_ecc_codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess"
}

#操作ec2的权限
resource "aws_iam_role_policy_attachment" "applcation_ecc_codebuild_role_attach_AmazonEC2FullAccess" {

  role       = aws_iam_role.applcation_ecc_codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

#操作ecr的权限
resource "aws_iam_role_policy_attachment" "applcation_ecc_codebuild_role_attach_AmazonEC2ContainerRegistryFullAccess" {
  role       = aws_iam_role.applcation_ecc_codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

#操作s3的权限
resource "aws_iam_role_policy_attachment" "applcation_ecc_codebuild_role_attach_AmazonS3FullAccess" {
  role       = aws_iam_role.applcation_ecc_codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

#允许ec2拉取ecr中的镜像
resource "aws_iam_role_policy_attachment" "applcation_ecc_codebuild_role_attach_EC2ImageBuilderECR" {
  role       = aws_iam_role.applcation_ecc_codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
}

#ec2的codebuild
# 1. Service Role
# 用途：这是 CodeBuild 用于执行构建项目的 IAM 角色。
# 权限：该角色需要具有访问 AWS 服务的权限，例如：
# S3：用于读取和写入构建输入和输出。
# CloudWatch Logs：用于记录构建日志。
# ECR：用于推送和拉取 Docker 镜像（如果使用容器构建）。
# 其他服务：根据构建过程中需要访问的服务而定。
# 2. Resource Access Role
# 用途：这是用于 CodeBuild 在构建过程中访问其他 AWS 资源的角色。
# 权限：该角色通常用于访问特定的 AWS 资源，例如：
# 访问 S3 存储桶中的文件。
# 访问其他 AWS 服务（如 DynamoDB、SNS 等），具体取决于构建过程的需求。

resource "aws_codebuild_project" "application_ecc_codebuild" {
  count = var.mode =="ecc"?1:0
  name                 = "${var.perfix}_ecc_codebuild"
  description          = "${var.perfix}_ecc_codebuild"
  build_timeout        = 60  #1hours
  service_role         = aws_iam_role.applcation_ecc_codebuild_role.arn
  resource_access_role = aws_iam_role.applcation_ecc_codebuild_role.arn

  artifacts {
    type      = "S3"
    location  = aws_s3_bucket.application_artifacts_file.bucket
    packaging = "ZIP"
    path      = "/${var.perfix}_ecc_codebuild_artifacts/"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "REPO_HTTPS"
      value =  var.backend_repo
    }
    environment_variable {
      name  = "BRANCH"
      value = var.backend_ecc_branch
    }
  }
  source {
    type      = "NO_SOURCE"
    buildspec = file("./moudle/codepipeline/buildspec/code_compile_ec2.yml")
  }
  tags = {
    Name = "${var.perfix}_ecc_codebuild"
  }
}

#######ecs 部分###############
#ecs的codebuild role主要多了ecr部分
resource "aws_iam_role" "applcation_ecs_codebuild_role" {
  name               = "${var.perfix}_ecs_codebuild_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_to_codebuild.json
}

resource "aws_iam_role_policy" "applcation_ecs_codebuild_policy" {
  name   = "${var.perfix}_ecs_codebuild_policy"
  role   = aws_iam_role.applcation_ecs_codebuild_role.id
  policy = data.aws_iam_policy_document.application_ecs_codebuild_policy.json
}

resource "aws_iam_role_policy_attachment" "applcation_ecs_codebuild_role_attach_AmazonEC2ContainerRegistryPowerUser" {
  role       = aws_iam_role.applcation_ecs_codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy_attachment" "orjujeng_ecs_codebuild_role_attach_AmazonElasticContainerRegistryPublicFullAccess" {
  role       = aws_iam_role.applcation_ecs_codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticContainerRegistryPublicFullAccess"
}


####ecs codebuild compile
resource "aws_codebuild_project" "application_codebuild_ecs_compile" {
  count = var.mode =="ecs"?1:0
  name                 = "${var.perfix}_codebuild_ecs_compile"
  description          = "${var.perfix}_codebuild_ecs_compile"
  build_timeout        = 60
  service_role         = aws_iam_role.applcation_ecs_codebuild_role.arn
  resource_access_role = aws_iam_role.applcation_ecs_codebuild_role.arn

  artifacts {
    type      = "S3"
    location  = aws_s3_bucket.application_artifacts_file.bucket
    packaging = "ZIP"
    path      = "/${var.perfix}_ecs_codebuild_artifacts/"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    environment_variable {
      name  = "REPO_HTTPS"
      value =  var.backend_repo
    }
    environment_variable {
      name  = "BRANCH"
      value = var.backend_ecc_branch
    }
    environment_variable {
      name  = "ECR_REPO"
      value = var.ecr_repo
    }

     environment_variable {
      name  = "PERFIX"
      value = var.perfix
    }
  }

  source {
    type      = "NO_SOURCE"
    buildspec = file("./moudle/codepipeline/buildspec/code_compile_ecs.yml")
  }

  # vpc_config {
  #   vpc_id = aws_vpc.orjujeng_vpc.id

  #   subnets = [
  #     aws_subnet.orjujeng_inside_net_1a.id,
  #     aws_subnet.orjujeng_inside_net_1c.id,
  #   ]

  #   security_group_ids = [
  #     aws_security_group.orjujeng_codebuild_sg.id
  #   ]
  # }

  tags = {
    Name = "${var.perfix}_codebuild_ecs_compile"
  }
}