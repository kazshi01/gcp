locals {
  project_id = "encoded-copilot-453019-e7"
  region = "asia-northeast1"

  artifact_registry_repo_name = "test-repo"
  
  github_repo = "kazshi01/gcp"

  github_actions = {
    service_account_name            = "github-actions"
    workload_identity_pool_name     = "github-actions-pool"
    workload_identity_provider_name = "github-actions-provider"
  }

  github_actions_roles = [
    "roles/run.admin",
    "roles/iam.serviceAccountUser",
    "roles/artifactregistry.writer"
  ]
}
