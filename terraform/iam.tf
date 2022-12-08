resource "aws_iam_role" "lambda_assume" {
  name = "lambda-assume"

  assume_role_policy = jsonencode(
  {
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "LambdaAssumeRole"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect = "Allow"
      }
    ]
  })
}
// TODO : RM?
resource "aws_iam_role" "ec2_assume" {
  name = "ec2-assume"

  assume_role_policy = jsonencode(
  {
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "Ec2AssumeRole"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"
      }
    ]
  })
}


## ECS
#
resource "aws_iam_role" "ecs" {
  name = "bmlt-ecs"

  assume_role_policy = jsonencode(
  {
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "Ec2AssumeRole"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_attach_ecs_policy" {
  role       = aws_iam_role.ecs.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_attach_ecr_policy" {
  role       = aws_iam_role.ecs.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "ecs_attach_ssm_policy" {
  role       = aws_iam_role.ecs.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "ecs_allow_logging_policy" {
  name = aws_iam_role.ecs.name
  role = aws_iam_role.ecs.name

  policy = jsonencode(
  {
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        Resource = [
          "arn:aws:logs:*:*:*"
        ]
      }
    ]
  }
  )
}

resource "aws_iam_instance_profile" "ecs" {
  name = "bmlt-ecs"
  role = aws_iam_role.ecs.name
}


## ECS Task
#
data "aws_iam_policy_document" "ecs_task_role_assume_policy" {
  statement {
    sid    = "ecsTask"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "ecs_execute_command" {
  statement {
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [data.aws_secretsmanager_secret.docker.arn]
  }
}

resource "aws_iam_policy" "ecs_execute_command" {
  name        = "ecs-execute-command"
  description = "Allows execution of remote commands on ECS"
  policy      = data.aws_iam_policy_document.ecs_execute_command.json
}

// TODO: Remove
resource "aws_iam_role" "ecs_task_role" {
  name               = "ecs-exec-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_role_assume_policy.json

  tags = { Name = "ecs-exec-task-role" }
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_execute_command_attachment" {
  policy_arn = aws_iam_policy.ecs_execute_command.arn
  role       = aws_iam_role.ecs_task_role.name
}
//

resource "aws_iam_role" "ecs_task" {
  name               = "ecs-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_role_assume_policy.json

  tags = { Name = "ecs-task" }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execute_command_attachment" {
  policy_arn = aws_iam_policy.ecs_execute_command.arn
  role       = aws_iam_role.ecs_task.name
}

resource "aws_iam_role" "ecs_service" {
  name = "ecs-service"

  assume_role_policy = jsonencode(
  {
    Version = "2008-10-17"
    Statement = [
      {
        Sid    = ""
        Effect = "Allow"
        Principal = {
          Service = "ecs.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  }
  )
}

resource "aws_iam_role_policy" "ecs_service" {
  name = aws_iam_role.ecs_service.name
  role = aws_iam_role.ecs_service.name

  policy = jsonencode(
  {
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:Describe*",
          "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:Describe*",
          "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
          "elasticloadbalancing:RegisterTargets"
        ],
        Resource = "*"
      }
    ]
  })
}
