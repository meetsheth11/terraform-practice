module "networking" {
  source         = "./networking"
  security_groups  = local.security_groups
  access_ip        = var.access_ip
#   public_subnets = ["10.123.2.0/24"]
}

module "server" {
  source         = "./server"
  public_subnets = module.networking.public_subnets
  public_sg      = module.networking.public_sg
  vol_size       = "20"
}