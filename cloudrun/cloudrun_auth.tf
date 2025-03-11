resource "google_cloudbuildv2_connection" "github_connection" {
  location = "asia-northeast1"
  name = "github-connection"

  github_config {
    app_installation_id = local.github_app_installation_id
    authorizer_credential {
      oauth_token_secret_version = local.github_oauth_token_secret_version
    }
  }
}

resource "google_cloudbuildv2_repository" "github_repository" {
  name = "github-repository"
  parent_connection = google_cloudbuildv2_connection.github_connection.id
  remote_uri = local.github_repository_remote_uri
}

resource "google_project_iam_member" "cloudbuild_iam" {
  for_each = toset([
    "roles/run.admin",
    "roles/iam.serviceAccountUser",
    "roles/secretmanager.secretAccessor",
  ])
  role    = each.key
  member  = "serviceAccount:${local.project_number}@cloudbuild.gserviceaccount.com"
  project = local.project_id
}
