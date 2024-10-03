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



#resource "ibm_resource_group" "group" {
#  name = "${local.basename}"
 # tags = var.tags
#}

resource "ibm_iam_access_group" "administrators" {
  name        = "${local.basename}-administrators"
  description = "Administrators for ${local.basename}"
  tags        = var.tags
}

resource "ibm_iam_access_group" "operators" {
  name        = "${local.basename}-operators"
  description = "Operators for ${local.basename}"
  tags        = var.tags
}

resource "ibm_iam_access_group" "developers" {
  name        = "${local.basename}-developers"
  description = "Developers for ${local.basename}"
  tags        = var.tags
}

resource "ibm_is_vpc" "vpc" {
  resource_group              = ibm_resource_group.group.id
  name                        = "${local.basename}-vpc"
  default_security_group_name = "${local.basename}-sec-group"
  default_network_acl_name    = "${local.basename}-acl-group"
  default_routing_table_name  = "${local.basename}-routing-table"
  tags                        = var.tags
}

output "vpc_id" {
  description = "ID of the created VPC"
  value       = ibm_is_vpc.vpc.id
}
