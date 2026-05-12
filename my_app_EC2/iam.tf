resource "aws_iam_role" "github_oidc" {
  name = "zzw-github-access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = "arn:aws:iam::558931385457:oidc-provider/token.actions.githubusercontent.com"
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }

          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:lilac-zhang/zzw-myapp:ref:refs/heads/main"
          }
        }
      }
    ]
  })
}