terraform {
  backend "local" {
    path = "terraform.tfstate"
  }

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
  }
}

provider "github" {
  token = var.token
  owner = "CityBaseInc"
}
