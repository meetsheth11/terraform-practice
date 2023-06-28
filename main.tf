module "networking" {
  source          = "./networking"
  security_groups = local.security_groups
  access_ip       = var.access_ip
  #   public_subnets = ["10.123.2.0/24","10.123.4.0/24"]
  public_cidrs = [for i in range(2, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]
  private_cidrs = [for i in range(1, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]
  max_subnets  = 20
}



module "loadbalancing" {
  source                  = "./loadbalancing"
  public_sg               = module.networking.meet_public_sg
  public_subnets          = module.networking.public_subnets
  tg_port                 = 8000
  tg_protocol             = "HTTP"
  vpc_id                  = module.networking.vpc_id
  elb_healthy_threshold   = 10
  elb_unhealthy_threshold = 2
  elb_timeout             = 20
  elb_interval            = 25
  listener_port           = 80
  listener_protocol       = "HTTP"
}

module "ecs" {
  source              = "./ecs"
  public_sg           = module.networking.meet_public_sg
  public_subnets      = module.networking.public_subnets
  private_subnets     = module.networking.private_subnets
  aws_lb_target_group = module.loadbalancing.aws_lb_target_group
  aws_lb_listener     = module.loadbalancing.aws_lb_listener
  aws_lb = module.loadbalancing.aws_lb
  listener_port           = 80
  listener_protocol       = "HTTP"
}