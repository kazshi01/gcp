resource "google_service_account" "cloudbuild_service_account" {
  account_id   = "cloudbuild-sa"
  display_name = "cloudbuild-sa"
  description  = "Cloud build service account"
}

resource "google_project_iam_member" "act_as" {
  project = local.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.cloudbuild_service_account.email}"
}

resource "google_project_iam_member" "logs_writer" {
  project = local.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloudbuild_service_account.email}"
}

# 追加の必要な権限
resource "google_project_iam_member" "run_admin" {
  project = local.project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.cloudbuild_service_account.email}"
}

resource "google_project_iam_member" "secret_accessor" {
  project = local.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.cloudbuild_service_account.email}"
}

# Cloud Storage バケットを作成してビルドログを保存
resource "google_storage_bucket" "cloudbuild_logs" {
  name     = "${local.project_id}-cloudbuild-logs"
  location = local.region
  uniform_bucket_level_access = true
}

# サービスアカウントにバケットへのアクセス権を付与
resource "google_storage_bucket_iam_member" "cloudbuild_logs_writer" {
  bucket = google_storage_bucket.cloudbuild_logs.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.cloudbuild_service_account.email}"
}

resource "google_cloudbuild_trigger" "github" {
  location = local.region

  repository_event_config {
    repository = google_cloudbuildv2_repository.github_repository.id
    push {
      branch = "^main$"
    }
  }

  filename = "cloudrun/cloudbuild.yaml"

  # これがないと400エラーになる
  # 仕様変更: https://blog.g-gen.co.jp/entry/cloud-build-service-account-changes
  service_account = google_service_account.cloudbuild_service_account.id
  
  include_build_logs = "INCLUDE_BUILD_LOGS_WITH_STATUS"
}
