resource "aws_dynamodb_table" "visitor_counter" {
  name                        = "visitor-counter-prod"
  billing_mode                = "PAY_PER_REQUEST"
  hash_key                    = "counter_id"
  table_class                 = "STANDARD"
  deletion_protection_enabled = false

  # Hash key attribute definition
  attribute {
    name = "counter_id"
    type = "S"
  }

  tags = {
    Environment = "Production"  # Keep existing
    Project     = "CloudResume" # Keep existing
  }

  point_in_time_recovery {
    enabled = true
  }

  ttl {
    enabled        = false
    attribute_name = ""
  }

  stream_enabled = false
}
