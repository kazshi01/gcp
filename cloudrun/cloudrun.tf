########################################################
# Cloud Runサービスの作成
########################################################
resource "google_cloud_run_v2_service" "default" {
  name                = "cloudrun-service"
  location            = "asia-northeast1"
  deletion_protection = false

  # ロードバランサーと内部トラフィックのみ許可
  ingress = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  template {
    containers {
      # 互換性のあるNginxイメージを使用
      image = "nginx:stable"
      
      # Nginxのポート設定
      ports {
        container_port = 80
      }
      
      # 環境変数の設定
      env {
        name  = "ENV"
        value = "dev"
      }

      # ヘルスチェックの設定
      startup_probe {
        initial_delay_seconds = 3
        timeout_seconds       = 2
        period_seconds        = 5
        failure_threshold     = 1
        tcp_socket {
          port = 80
        }
      }
    }

    # サービスアカウント
    service_account = google_service_account.cloudrun_sa.email
  }

  lifecycle {
    ignore_changes = [
      template[0].containers[0].image,
    ]
  }

}

# Cloud Run用のサービスアカウント
resource "google_service_account" "cloudrun_sa" {
  account_id   = "cloudrun-service-sa"
  display_name = "Cloud Run Service Account"
}

########################################################
# Cloud Run用のネットワークエンドポイントグループ(NEG)
########################################################
resource "google_compute_region_network_endpoint_group" "cloudrun_neg" {
  name                  = "cloudrun-neg"
  network_endpoint_type = "SERVERLESS"
  region                = "asia-northeast1"

  cloud_run {
    service = google_cloud_run_v2_service.default.name
  }
}

########################################################
# 一般ユーザーにアクセス権を付与
########################################################
resource "google_cloud_run_v2_service_iam_member" "all_users" {
  location = google_cloud_run_v2_service.default.location
  name     = google_cloud_run_v2_service.default.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
