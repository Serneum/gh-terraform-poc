module "pos-frontend" {
  source = "../"

  name        = "pos-frontend"
  description = "Frontend web app for the POS system"

  required_status_checks = ["Testing"]
  autolink_references    = ["KCORE"]
  require_code_owner_reviews = true
}
