# AWS modules

Phase 2A provides reusable modules for:

- `ecr`: immutable repositories, scan-on-push, and a bounded image lifecycle.
- `network`: VPC, public/private subnets, routing, security groups, and an
  optional single NAT gateway.
- `ecs-cluster`: Fargate cluster with optional Container Insights.
- `ecs-service`: Fargate task definition/service, execution/task roles,
  CloudWatch logging, container health checks, and optional Secrets Manager
  injection.
- `alb`: public HTTP ALB with frontend default routing and backend rules for
  `/api/*`, `/health`, and `/readyz`.
- `logging`: CloudWatch log groups with explicit retention.

The development root defaults to public ECS tasks and no NAT gateway to keep
costs low. Private tasks require enabling a NAT gateway and incur additional
hourly and data-processing charges.
