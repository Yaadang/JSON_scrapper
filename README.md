# JSON_scrapper
# Terraform AWS Configuration

This Terraform configuration sets up an AWS infrastructure for a data processing pipeline. The configuration includes the creation of an S3 bucket, an AWS Lambda function, and necessary IAM policies and permissions.

## Prerequisites

Before using this Terraform configuration, make sure you have the following prerequisites installed on your system:

- [Terraform](https://www.terraform.io/)
- AWS CLI configured with appropriate credentials

## Overview

This Terraform configuration creates an AWS infrastructure to set up a data processing pipeline. The key components of this configuration include:

- An S3 bucket (`aws_s3_bucket.data_bucket`) for storing data files.
- An AWS Lambda function (`aws_lambda_function.jsonParse`) to process the data.
- IAM policies and permissions to grant the Lambda function access to necessary AWS services.

## Getting Started

### Installation

Follow these steps to apply the Terraform configuration:

1. Clone this repository:

   ```bash
   git clone https://github.com/yourusername/your-terraform-project.git

2. Navigate to the project directory:

```bash

cd your-terraform-project

3. Initialize the Terraform workspace:

```bash

terraform init

4. Apply the configuration:

```bash

terraform apply


