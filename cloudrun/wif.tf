# GitHub Actions用のサービスアカウントの作成
resource "google_service_account" "github_actions" {
  account_id   = local.github_actions.service_account_name
  display_name = "Service Account for GitHub Actions"
  description  = "Used for deploying to Cloud Run from GitHub Actions"
  project      = local.project_id
}

# GitHub Actions用サービスアカウントに必要な権限の付与
resource "google_project_iam_member" "binding" {
  for_each = toset(local.github_actions_roles)
  
  project = local.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# Workload Identity Poolの作成
resource "google_iam_workload_identity_pool" "github_pool" {
  workload_identity_pool_id = local.github_actions.workload_identity_pool_name
  project                   = local.project_id
  display_name              = "GitHub Actions Pool"
  description               = "Workload Identity Pool for GitHub Actions"
}

# Workload Identity Providerの作成
resource "google_iam_workload_identity_pool_provider" "github_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = local.github_actions.workload_identity_provider_name
  project                            = local.project_id
  
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
    "attribute.ref"        = "assertion.ref"
  }
  
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  attribute_condition = "attribute.repository == \"${local.github_repo}\""
}

# Workload Identity PoolとGitHub Actions用のサービスアカウントの紐付け
resource "google_service_account_iam_member" "workload_identity_user" {
  service_account_id = google_service_account.github_actions.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${local.github_repo}"
}

########################################################
# GitHub Actions用のSecretsに必要な情報を出力
########################################################
output "github_actions" {
  value = {
    PROJECT_ID                  = local.project_id
    WIF_PROVIDER                = "projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.github_pool.workload_identity_pool_id}/providers/${google_iam_workload_identity_pool_provider.github_provider.workload_identity_pool_provider_id}"
    SA_EMAIL                    = google_service_account.github_actions.email
    ARTIFACT_REGISTRY_REPO_NAME = local.artifact_registry_repo_name
  }
  description = "GitHub Actions用の設定情報"
}

data "google_project" "project" {
  project_id = local.project_id
}
