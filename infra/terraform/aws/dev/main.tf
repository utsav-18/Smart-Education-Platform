locals {
  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags,
  )
}

check "private_subnet_requires_nat" {
  assert {
    condition     = !var.use_private_subnets || var.enable_nat_gateway
    error_message = "use_private_subnets=true requires enable_nat_gateway=true so ECS tasks can reach ECR, CloudWatch, and Secrets Manager."
  }
}

module "ecr" {
  source = "../../modules/aws/ecr"

  repositories = {
    frontend = {
      name = "${var.project_name}-${var.environment}-frontend"
    }
    backend = {
      name = "${var.project_name}-${var.environment}-backend"
    }
  }

  tags = local.common_tags
}

module "network" {
  source = "../../modules/aws/network"

  name                 = "${var.project_name}-${var.environment}"
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_nat_gateway   = var.enable_nat_gateway
  tags                 = local.common_tags
}

module "logging" {
  source = "../../modules/aws/logging"

  log_groups = {
    frontend = "/ecs/${var.project_name}/${var.environment}/frontend"
    backend  = "/ecs/${var.project_name}/${var.environment}/backend"
  }

  retention_in_days = var.log_retention_in_days
  tags              = local.common_tags
}

module "cluster" {
  source = "../../modules/aws/ecs-cluster"

  name                      = "${var.project_name}-${var.environment}"
  enable_container_insights = var.enable_container_insights
  tags                      = local.common_tags
}

module "alb" {
  source = "../../modules/aws/alb"

  name              = "${var.project_name}-${var.environment}"
  vpc_id            = module.network.vpc_id
  subnet_ids        = module.network.public_subnet_ids
  security_group_id = module.network.alb_security_group_id
  tags              = local.common_tags
}

locals {
  service_subnet_ids = var.use_private_subnets ? module.network.private_subnet_ids : module.network.public_subnet_ids
  assign_public_ip   = !var.use_private_subnets
  backend_environment = {
    PORT          = "5000"
    NODE_ENV      = "production"
    CLIENT_ORIGIN = var.frontend_origin
  }
}

module "frontend_service" {
  source = "../../modules/aws/ecs-service"

  name                 = "${var.project_name}-${var.environment}-frontend"
  cluster_arn          = module.cluster.cluster_arn
  image                = var.container_images.frontend
  container_port       = 80
  desired_count        = var.desired_count
  subnet_ids           = local.service_subnet_ids
  security_group_ids   = [module.network.service_security_group_id]
  assign_public_ip     = local.assign_public_ip
  target_group_arn     = module.alb.frontend_target_group_arn
  health_check_command = ["CMD-SHELL", "wget -q --spider http://127.0.0.1/ || exit 1"]
  log_group_name       = module.logging.log_group_names.frontend
  aws_region           = var.aws_region
  tags                 = local.common_tags
}

module "backend_service" {
  source = "../../modules/aws/ecs-service"

  name               = "${var.project_name}-${var.environment}-backend"
  cluster_arn        = module.cluster.cluster_arn
  image              = var.container_images.backend
  container_port     = 5000
  desired_count      = var.desired_count
  subnet_ids         = local.service_subnet_ids
  security_group_ids = [module.network.service_security_group_id]
  assign_public_ip   = local.assign_public_ip
  target_group_arn   = module.alb.backend_target_group_arn
  environment        = local.backend_environment
  secrets = var.mongo_uri_secret_arn == null ? [] : [{
    name       = "MONGO_URI"
    value_from = var.mongo_uri_secret_arn
  }]
  secret_arns          = var.mongo_uri_secret_arn == null ? [] : [var.mongo_uri_secret_arn]
  health_check_command = ["CMD-SHELL", "node -e \"fetch('http://localhost:5000/readyz').then((r) => process.exit(r.ok ? 0 : 1)).catch(() => process.exit(1))\""]
  log_group_name       = module.logging.log_group_names.backend
  aws_region           = var.aws_region
  tags                 = local.common_tags
}
