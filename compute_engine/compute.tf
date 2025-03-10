# GCE用のサービスアカウント（オプション）
resource "google_service_account" "gce_service_account" {
  account_id   = "gce-service-account"
  display_name = "GCE Service Account"
}

# 永続ディスクの作成
resource "google_compute_disk" "boot_disk" {
  name  = "gce-boot-disk"
  type  = "pd-standard"  # 標準永続ディスク、pd-ssdも選択可能
  size  = 20  # GBサイズ
  zone  = "asia-northeast1-a"
  image = "debian-cloud/debian-11"  # 必要に応じてOSイメージを変更
}

# GCEインスタンスの作成
resource "google_compute_instance" "vm_instance" {
  name         = "my-instance"
  machine_type = "e2-medium"  # インスタンスタイプ
  tags         = ["lb-backend"]

  boot_disk {
    source = google_compute_disk.boot_disk.self_link
  }

  # 削除保護（オプション）
  deletion_protection = false

  # サブネットワークインターフェース
  network_interface {
    network    = google_compute_network.vpc_network.name
    subnetwork = google_compute_subnetwork.subnet.name
  }

  # サービスアカウントの設定
  service_account {
    email  = google_service_account.gce_service_account.email
    scopes = ["cloud-platform"]  # 本番環境では必要最小限のスコープに制限することを推奨
  }

  # スタートアップスクリプト（オプション）
  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    service nginx start
  EOF
}
