variable "name" {
  type        = string
  description = "The name of the GitHub repository."
}

variable "description" {
  type        = string
  description = "The description of the GitHub repository."
  default     = ""
}

variable "visibility" {
  type        = string
  description = "The visibility of the GitHub repository: public or private. Defaults to private."
  default     = "private"

  validation {
    condition     = var.visibility == "public" || var.visibility == "private"
    error_message = "Visibility must be set to either public or private."
  }
}

variable "required_status_checks" {
  type        = list(string)
  description = "The list of required status checks before a pull request can be merged in for the repository."
  default     = []
}

variable "autolink_references" {
  type        = list(string)
  description = "The list of autolink references to create on the repository. These should line up with the JIRA issue names, like KCORE and KOPS"
  default     = []
}

variable "require_code_owner_reviews" {
  type        = bool
  description = "Require an approved review in pull requests from a designated code owner."
  default     = false
}
