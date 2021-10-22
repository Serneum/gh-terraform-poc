module "cb-pos" {
  source = "git@github.com:Serneum/gh-terraform-poc.git?ref=v0.1.0"

  name        = "cb_pos"
  description = "CityBase Point of Sale"

  required_status_checks = ["Testing (11.8)"]
  autolink_references    = ["KCORE"]
  require_code_owner_reviews = true

  team_permissions = [
    { id = data.github_team.in-person.id, permission = "push" }
  ]
}
