# terraform_actions

This repo provisions an EC2 instance with Terraform, clones this public repository onto that instance, builds the Docker image, and runs the FastAPI app so it is reachable from the browser.

## Repo structure

- `app/`: FastAPI application code
- `Dockerfile`: container image definition
- `infra/`: Terraform for EC2, security group, bootstrap script, and outputs
- `.github/workflows/`: GitHub Actions for validation and deployment

## How deployment works

1. A push to `main` that changes `app/**`, `infra/**`, `Dockerfile`, or `requirements.txt` triggers the deploy workflow.
2. GitHub Actions runs `terraform init`, `plan`, and `apply`.
3. Terraform creates or updates an EC2 instance in the default VPC.
4. EC2 `user_data` installs Docker and Git, clones this repo into `/opt/terraform_actions`, builds the Docker image, and starts the container.
5. The app is exposed on port `80`, so the output URL is directly browser-friendly.
6. An Elastic IP is attached so the public address stays stable across redeployments.

The deployment intentionally hashes the app source, `Dockerfile`, and `requirements.txt`. When those files change, Terraform replaces the EC2 instance so the bootstrap script runs again from a clean machine.

Terraform state is kept local to the workflow and restored from GitHub Actions cache between runs. That avoids extra AWS resources like an S3 backend bucket or DynamoDB lock table.

## GitHub Actions prerequisites

Create these GitHub repository secrets:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

Create these GitHub repository variables:

- `AWS_REGION`: for example `ap-south-1`

## Manual destroy

Use the `Deploy EC2 App` workflow with `terraform_action=destroy` when you want to tear the environment down and stop AWS charges.

## Notes

- This setup assumes your AWS account has a default VPC and default subnets in the chosen region.
- The repository is cloned from its public HTTPS URL, so no SSH key is needed on the EC2 instance.
- The FastAPI app returns JSON at `/` and a health response at `/health`.
- The GitHub Actions cache approach is intentionally lightweight for learning and simple solo use. For team or production usage, a real remote backend is safer.
