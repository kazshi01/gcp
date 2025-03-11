# Cloud Buildトリガーの設定
resource "google_cloudbuild_trigger" "cloudrun-build-trigger" {
  # GitHub連携を使用する設定
  github {
    owner = "kazshi01"  
    name  = "gcp"       
    push {
      branch = "^main$" 
    }
  }

  filename = "cloudrun/cloudbuild.yaml"
}
