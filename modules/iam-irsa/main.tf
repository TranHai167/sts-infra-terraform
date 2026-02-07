data "aws_iam_policy_document" "assume_role" {
  for_each = var.roles

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_url}:sub"
      values   = ["system:serviceaccount:${each.value.namespace}:${each.value.service_account}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_url}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  for_each = var.roles

  name               = each.value.role_name
  path               = lookup(each.value, "role_path", "/")
  assume_role_policy = data.aws_iam_policy_document.assume_role[each.key].json
}

locals {
  policy_attachments = flatten([
    for role_key, role in var.roles : [
      for policy_arn in role.policy_arns : {
        key        = "${role_key}|${policy_arn}"
        role_key   = role_key
        policy_arn = policy_arn
      }
    ]
  ])
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = { for item in local.policy_attachments : item.key => item }

  role       = aws_iam_role.this[each.value.role_key].name
  policy_arn = each.value.policy_arn
}
