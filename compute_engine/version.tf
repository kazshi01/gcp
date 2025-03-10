# Terraformのプロバイダー設定
provider "google" {
  project = "encoded-copilot-453019-e7"  # プロジェクトID
  region  = "asia-northeast1"  # 東京リージョン
  zone    = "asia-northeast1-a"
}

terraform {
  backend "gcs" {
    bucket  = "terraformstate_backet"
    prefix  = "compute_engine"
  }
}
