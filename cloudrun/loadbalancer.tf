# グローバル用の静的IPアドレスの作成
resource "google_compute_global_address" "lb_ip" {
  name = "lb-static-ip"
}

########################################################
# バックエンドサービスの作成　※LBがどこにアクセスするか
########################################################
resource "google_compute_backend_service" "default" {
  name                  = "web-backend-service"
  protocol              = "HTTP"
  timeout_sec           = 30
  load_balancing_scheme = "EXTERNAL_MANAGED"
  security_policy       = google_compute_security_policy.policy.id

  # Cloud Run NEGを使用
  backend {
    group = google_compute_region_network_endpoint_group.cloudrun_neg.id
  }

  # カスタムリクエストヘッダーの追加
  custom_request_headers = [
    "X-LB-Auth: lb-secret-token-12345", # Cloud Runへの認証ヘッダー
  ]
}

########################################################
# HTTP forwarding rule（フロントエンド）※LBがどこからアクセスを受け付けるか
########################################################
# URLマップの作成
resource "google_compute_url_map" "default" {
  name            = "cloudrun-url-map"
  default_service = google_compute_backend_service.default.id
}

# HTTPプロキシ
resource "google_compute_target_http_proxy" "default" {
  name    = "cloudrun-http-proxy"
  url_map = google_compute_url_map.default.id
}

# グローバルロードバランサー用HTTPフォワーディングルール
resource "google_compute_global_forwarding_rule" "http" {
  name                  = "http-forwarding-rule"
  target                = google_compute_target_http_proxy.default.id
  port_range            = "80"
  ip_address            = google_compute_global_address.lb_ip.address
  load_balancing_scheme = "EXTERNAL_MANAGED"
}

########################################################
# Cloud Armorセキュリティポリシー(WAF)
########################################################
resource "google_compute_security_policy" "policy" {
  name = "lb-security-policy"

  # すべてのトラフィックを許可（デフォルトルール）
  rule {
    action   = "allow"
    priority = 2147483647
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "すべてのトラフィックを許可（デフォルト）"
  }

  # 基本的なWAF保護（SQLインジェクション対策）- オプション
  rule {
    action   = "deny(403)"
    priority = 1000
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('sqli-stable')"
      }
    }
    description = "SQLインジェクション対策"
  }

  # XSS対策 - オプション
  rule {
    action   = "deny(403)"
    priority = 1001
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('xss-stable')"
      }
    }
    description = "XSS対策"
  }
}
