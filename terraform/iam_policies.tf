data "aws_iam_policy_document" "ci_minimal" {
  statement {
    sid = "TerraformStateBucket"

    actions = [
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      aws_s3_bucket.tf_state.arn,
      "${aws_s3_bucket.tf_state.arn}/*"
    ]
  }

  statement {
    sid = "TerraformIAM"
    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:PutRolePolicy",
      "iam:GetRole",
      "iam:TagRole",
      "iam:DetachRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:AttachRolePolicy",
      "iam:CreateInstanceProfile",
      "iam:DeleteInstanceProfile",
      "iam:AddRoleToInstanceProfile",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:PassRole",
      "iam:CreatePolicy",
      "iam:DeletePolicy",
      "iam:CreatePolicyVersion",
      "iam:UpdateRole",
      "iam:DeletePolicyVersion"
    ]
    resources = ["*"]
  }

  statement {
    sid = "TerraformEC2"
    actions = [
      "ec2:CreateVpc",
      "ec2:DeleteVpc",
      "ec2:ModifyVpcAttribute",
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:CreateInternetGateway",
      "ec2:AttachInternetGateway",
      "ec2:DeleteInternetGateway",
      "ec2:CreateSubnet",
      "ec2:AttachSubnet",
      "ec2:DetachSubnet",
      "ec2:ModifyRoute",
      "ec2:DeleteSubnet",
      "ec2:ModifySubnetAttribute",
      "ec2:CreateRouteTable",
      "ec2:DeleteRouteTable",
      "ec2:CreateRoute",
      "ec2:DeleteRoute",
      "ec2:ReplaceRoute",
      "ec2:AssociateRouteTable",
      "ec2:DisassociateRouteTable",
      "ec2:CreateSecurityGroup",
      "ec2:DeleteSecurityGroup",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:AllocateAddress",
      "ec2:ReleaseAddress",
      "ec2:CreateNatGateway",
      "ec2:DeleteNatGateway",
      "ec2:RunInstances",
      "ec2:TerminateInstances"
    ]
    resources = ["*"]
  }

  statement {
    sid = "TerraformRDS"
    actions = [
      "rds:CreateDBSubnetGroup",
      "rds:DeleteDBSubnetGroup",
      "rds:ModifyDBSubnetGroup",
      "rds:CreateDBCluster",
      "rds:DeleteDBCluster",
      "rds:ModifyDBCluster",
      "rds:CreateDBInstance",
      "rds:DeleteDBInstance",
      "rds:ModifyDBInstance",
      "rds:CreateDBProxy",
      "rds:DeleteDBProxy",
      "rds:ModifyDBProxy",
      "rds:ModifyDBProxyTargetGroup",
      "rds:RegisterDBProxyTargets",
      "rds:DeregisterDBProxyTargets",
      "rds:CreateDBProxyTargetGroup",
      "rds:DeleteDBProxyTargetGroup",
      "rds:AddRoleToDBCluster",
      "rds:AddTagsToResource",
      "rds:RemoveRoleFromDBCluster"
    ]
    resources = ["*"]
  }

  statement {
    sid = "TerraformSecretsManager"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:DescribeSecret",
      "secretsmanager:TagResource",
      "secretsmanager:CreateSecret",
      "secretsmanager:DeleteSecret",
      "secretsmanager:UpdateSecret",
      "secretsmanager:PutSecretValue"
    ]
    resources = ["*"]
  }

  statement {
    sid = "TerraformSSM"
    actions = [
      "ssm:StartSession",
      "ssm:TerminateSession",
      "ssm:GetConnectionStatus",
      "ssm:DescribeSessions"
    ]
    resources = ["*"]
  }
}
