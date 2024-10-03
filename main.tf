variable "region" {
  type        = string
  default     = "us-south"
  description = "The region where to deploy the resources"
}

variable "tags" {
  type    = list(string)
  default = ["terraform", "simple-da"]
}

provider "ibm" {
  region = var.region
}

variable "prefix" {
  type        = string
  default     = ""
  description = "A prefix for all resources to be created. If none provided a random prefix will be created"
}

resource "random_string" "random" {
  count = var.prefix == "" ? 1 : 0

  length  = 6
  special = false
}

locals {
  # Use a conditional expression to avoid indexing errors
  basename = lower(var.prefix == "" ? "simple-da-${random_string.random[0].result}" : var.prefix)
}

data "ibm_resource_group" "group" {
  name = "default"
}
resource "ibm_cloudant" "cloudant" {
  name     = "cloudant-service-name"
  location = "us-south"
  plan     = "lite"

  legacy_credentials  = true
  include_data_events = false
  capacity            = 1
  enable_cors         = true

  cors_config {
    allow_credentials = false
    origins           = ["https://example.com"]
  }

  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}

#output "vpc_id" {
#  description = "ID of the created VPC"
#  value       = ibm_is_vpc.vpc.id
#}
