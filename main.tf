# terraform import module.pos-frontend.github_repository.repo pos-frontend
resource "github_repository" "repo" {
  name        = var.name
  description = var.description
  visibility  = var.visibility

  allow_auto_merge   = true
  allow_merge_commit = true
  allow_squash_merge = false
  allow_rebase_merge = false

  delete_branch_on_merge = true
  vulnerability_alerts   = true

  # I suspect we can remove these without issue
  has_downloads = true
  has_issues    = true
  has_projects  = true
  has_wiki      = true
}

# terraform import module.pos-frontend.github_repository_autolink_reference.autolink_reference['KCORE'] pos-frontend/99589
resource "github_repository_autolink_reference" "autolink_reference" {
  for_each = toset(var.autolink_references)
  repository = github_repository.repo.name
  key_prefix = "${each.key}-"
  target_url_template = "https://citybase.atlassian.net/browse/${each.key}-<num>"
}

# terraform import module.pos-frontend.github_branch.master pos-frontend:master
resource "github_branch" "master" {
  repository = github_repository.repo.name
  branch     = "master"
}

# terraform import module.pos-frontend.github_branch_default.default pos-frontend
resource "github_branch_default" "default" {
  repository = github_repository.repo.name
  branch     = github_branch.master.branch
}

# terraform import module.pos-frontend.github_branch_protection.branch-protection-master pos-frontend:master
resource "github_branch_protection" "branch-protection-master" {
  repository_id = github_repository.repo.node_id
  pattern       = github_branch.master.branch

  enforce_admins          = true
  require_signed_commits  = true
  required_linear_history = false

  required_status_checks {
    strict   = true
    contexts = var.required_status_checks
  }

  required_pull_request_reviews {
    required_approving_review_count = 2
    require_code_owner_reviews      = var.require_code_owner_reviews
  }
}
