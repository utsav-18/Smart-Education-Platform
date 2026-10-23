# Terraform foundation

This directory contains the Phase 1 Terraform foundation and Phase 2A AWS
development infrastructure for the Multi-Cloud
CI/CD System for Smart Education Platforms. It intentionally creates no cloud
resources. The AWS and Azure development roots are separate so a command run in
one directory cannot accidentally initialize or provision the other provider.

## Directory layout

```text
infra/terraform/
├── aws/
│   └── dev/
│       ├── backend.tf
│       ├── dev.tfvars.example
│       ├── main.tf
│       ├── outputs.tf
│       ├── providers.tf
│       ├── variables.tf
│       └── versions.tf
├── azure/
│   └── dev/
│       ├── backend.tf
│       ├── dev.tfvars.example
│       ├── main.tf
│       ├── outputs.tf
│       ├── providers.tf
│       ├── variables.tf
│       └── versions.tf
└── modules/
    ├── aws/
    │   ├── alb/
    │   ├── ecs-cluster/
    │   ├── ecs-service/
    │   ├── ecr/
    │   ├── logging/
    │   ├── network/
    │   └── README.md
    └── azure/README.md
```

### Root configurations

- `aws/dev/`: isolated AWS development root composing networking, ECR,
  ECS/Fargate, ALB, IAM, and CloudWatch modules.
- `azure/dev/`: isolated Azure development root. It will later compose Azure
  resource groups, ACR, Container Apps, ingress, identities, and observability
  modules.
- `backend.tf`: declares the intended remote-state backend without embedding
  account, subscription, bucket, container, or credential values.
- `dev.tfvars.example`: safe non-secret examples for local planning.
- `main.tf` and `outputs.tf`: AWS development composition and outputs.
- `modules/aws/`: reusable AWS modules used by the AWS development root.
- `modules/azure/`: reserved and unchanged for the future Azure implementation.

## Prerequisites

- Terraform `>= 1.6.0, < 2.0.0`
- AWS CLI for AWS work
- Azure CLI for Azure work
- Docker images published to the target ECR repositories before an ECS service
  deployment
- A reachable MongoDB deployment, such as MongoDB Atlas, for cloud runtime use

Terraform is not required to run the application locally. Local application
verification continues to use Docker Compose.

## Authentication

Credentials are never stored in Terraform files or `.tfvars` files.

For AWS, authenticate outside this repository with an AWS CLI profile, AWS SSO,
or short-lived environment credentials. For Azure, use `az login` and select
the intended subscription. Later GitHub Actions deployment should use OIDC
federation with narrowly scoped roles rather than long-lived keys.

Before any authenticated command, verify the selected account or subscription
with the relevant CLI. Do not use `terraform apply` until a reviewed plan and
an approved environment are available.

## State management

The root files declare remote backend types only; backend bootstrap is not part
of Phase 1. Create and secure the backend separately before enabling it:

- AWS: encrypted, versioned S3 state storage with restricted access and locking
  appropriate for the selected Terraform version.
- Azure: encrypted Azure Storage Blob state storage with restricted access,
  versioning, and recovery controls.

Never commit `.tfstate`, `.tfvars`, `.terraform/`, or backend credentials.
Remote state may contain sensitive values and must be treated as confidential.
Use distinct state keys for each cloud and environment.

For local syntax validation, use `terraform init -backend=false`; this avoids
contacting a remote backend.

## Validation

Run these commands independently in each root:

```powershell
cd infra/terraform/aws/dev
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
terraform plan -refresh=false -var-file=dev.tfvars.example
```

```powershell
cd infra/terraform/azure/dev
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
terraform plan -refresh=false -var-file=dev.tfvars.example
```

`fmt`, `init -backend=false`, `validate`, and a no-refresh plan are local
configuration checks, but provider plugins must still be downloadable.
Provider authentication is not required for these no-resource Phase 1 checks.
Authenticated `init` with a remote backend, refresh, plan against existing
infrastructure, and apply are deployment operations and are intentionally
out of scope.

## Cost controls

Phase 2A creates billable resources when applied. Before any apply:

- Use a dedicated development account or subscription.
- Review the complete plan and expected resource count.
- Start with one small replica per service and bounded CPU/memory.
- Set log retention and scaling limits explicitly.
- Review NAT gateway, load balancer, public IP, registry, logging, and egress
  costs.
- Add cloud budget alerts and consistent `project`, `environment`, and
  `managed-by` tags or labels.

The default development topology uses public subnets and public ECS task IPs
with no NAT gateway. This reduces cost and is less isolated than private tasks.
For a hardened topology, set `use_private_subnets = true` and
`enable_nat_gateway = true`; the NAT gateway is deliberately opt-in because it
adds hourly and data-processing charges. Do not place MongoDB in the public
subnets; use a managed MongoDB deployment with restricted network access.

Before ECS can start, publish both images to the ECR repository URLs from the
Terraform output. Terraform creates repositories but does not build or push
images. The MongoDB URI must be stored in AWS Secrets Manager separately, and
its ARN must be supplied as `mongo_uri_secret_arn`. The secret is injected at
runtime and is never stored in Terraform source.

## Cleanup

For a later environment, review the destroy plan before running:

```powershell
terraform plan -destroy -var-file=dev.tfvars
terraform destroy -var-file=dev.tfvars
```

Destroy application resources before deleting remote state. MongoDB Atlas or
other separately managed database resources require their own reviewed cleanup
procedure. Never delete state or databases as an incidental cleanup step.
