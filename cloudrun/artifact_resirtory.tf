# Artifact Registryリポジトリの作成
resource "google_artifact_registry_repository" "docker_repo" {
  location      = local.region
  repository_id = local.artifact_registry_repo_name
  description   = "Docker repository for GitHub Actions"
  format        = "DOCKER"
  project       = local.project_id
}
