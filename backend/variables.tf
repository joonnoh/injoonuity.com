# variables.tf

variable "table_name" {
  description = "DynamoDB table name (space is not allowed)"
  default     = "InjoonuityTable"
}

variable "table_billing_mode" {
  description = "Controls how you are charged for read and write throughput and how you manage capacity."
  default     = "PAY_PER_REQUEST"
}


variable "environment" {
  description = "Name of environment"
  default     = "test"
}
