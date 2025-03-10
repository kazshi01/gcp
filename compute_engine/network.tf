# VPCネットワークの作成
resource "google_compute_network" "vpc_network" {
  name                    = "my-custom-network"
  auto_create_subnetworks = false
  description             = "カスタムVPCネットワーク"
}

# サブネットの作成
resource "google_compute_subnetwork" "subnet" {
  name          = "my-custom-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = "asia-northeast1"
  network       = google_compute_network.vpc_network.id
}

# ロードバランサーからのアクセスのみを許可するファイアウォールルール
resource "google_compute_firewall" "lb_to_instances" {
  name    = "allow-lb-to-instances"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]  # 必要なポートを指定
  }

  # ロードバランサーのIPレンジからのトラフィックのみを許可
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]  # GCPロードバランサーのIPレンジ
  
  # lb-backendタグが付いたインスタンスにのみ適用
  target_tags = ["lb-backend"]
}
