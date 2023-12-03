# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------


# Generate an AWS provider block 
generate "provider" {
    path = "provider.tf"
    if_exists = "overwrite_terragrunt"
    contents = <<EOF 
provider "aws" {
    region = "${local.aws_region}"

    # Only these AWS Account IDs may be operate on by this template
    allowed_account_ids = ["${local.account_id}"]
}
EOF
}

# Configure Terragrunt to automatically store tfstate files in an S3 bucket 
remote_state {
    backend = "s3"
    config = {
        encrypt = true
        bucket = "terragrunt-state-${local.account_name}-${local.account_id}"
        key = "${path_relative_to_include()}/terraform.tfstate"
        region = local.aws_region
        dynamodb_table = "terraform-locks"
    }
    generate = {
        path = "backend.tf"
        if_exists = "overwrite_terragrunt"
    }
}
