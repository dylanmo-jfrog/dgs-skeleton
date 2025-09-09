import {
  id = "dgs-skeleton-terraform-state"
  to = aws_s3_bucket.terraform_state
}

import {
  id = "dgs-skeleton-terraform-lock"
  to = aws_dynamodb_table.terraform_locks
}
