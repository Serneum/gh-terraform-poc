module "cb-pos" {
  source = "../"

  name        = "cb_pos"
  description = "CityBase Point of Sale"

  required_status_checks = ["Testing (11.8)"]
  autolink_references    = ["KCORE"]
  require_code_owner_reviews = true
}
