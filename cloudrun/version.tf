# Terraformのプロバイダー設定
provider "google" {
  project = local.project_id  # プロジェクトID
  region  = local.region            # 東京リージョン
}

terraform {
  backend "gcs" {
    bucket  = "terraformstate_backet"
    prefix  = "cloudrun"
  }
}
