module "vpc" {
  source = "../../modules/vpc"

  vpc_name     = "dev-vpc"
  region       = var.region
  subnet_cidr  = "10.0.0.0/24"
}
