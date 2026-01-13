# Precondition checks for required variables
# Note: Terraform variable validation cannot reference other variables,
# so we use preconditions in resources instead

# Data source to get VPC CIDR block associations
# The aws_vpc resource doesn't expose cidr_block_associations directly,
# so we use a data source to retrieve this information
data "aws_vpc" "main" {
  id = aws_vpc.main.id
}
