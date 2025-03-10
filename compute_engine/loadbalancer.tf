# インスタンスグループの作成（ロードバランサー用）
resource "google_compute_instance_group" "webservers" {
  name        = "webserver-instance-group"
  description = "Webサーバーインスタンスグループ"
  zone        = "asia-northeast1-a"

  instances = [
    google_compute_instance.vm_instance.id
  ]

  named_port {
    name = "http"
    port = 80
  }

  # named_port {
  #   name = "https"
  #   port = 443
  # }
}

# グローバル用の静的IPアドレスの作成
resource "google_compute_global_address" "lb_ip" {
  name = "lb-static-ip"
}

# ヘルスチェックの作成
resource "google_compute_health_check" "default" {
  name               = "http-health-check"
  check_interval_sec = 5
  timeout_sec        = 5
  
  http_health_check {
    port         = 80
    request_path = "/"
  }
}

# バックエンドサービスの作成
resource "google_compute_backend_service" "default" {
  name                  = "web-backend-service"
  protocol              = "HTTP"
  port_name             = "http"
  timeout_sec           = 10
  load_balancing_scheme = "EXTERNAL_MANAGED"
  health_checks         = [google_compute_health_check.default.id]

  backend {
    group = google_compute_instance_group.webservers.id
  }
}

########################################################
# HTTP forwarding rule
########################################################

# HTTP→HTTPSリダイレクト用URLマップ
resource "google_compute_url_map" "http_redirect" {
  name   = "http-redirect"

  default_service = google_compute_backend_service.default.id

  # default_url_redirect {
  #   https_redirect         = true
  #   redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
  #   strip_query            = false
  # }
}

# HTTPプロキシ（リダイレクト用）
resource "google_compute_target_http_proxy" "http_redirect" {
  name    = "http-redirect-proxy"
  url_map = google_compute_url_map.http_redirect.id
}

# グローバルロードバランサー用HTTPリダイレクトフォワーディングルール
resource "google_compute_global_forwarding_rule" "http" {
  name                  = "http-forwarding-rule"
  target                = google_compute_target_http_proxy.http_redirect.id
  port_range            = "80"
  ip_address            = google_compute_global_address.lb_ip.address
  load_balancing_scheme = "EXTERNAL_MANAGED"
}

########################################################
# HTTPS forwarding rule
########################################################

# URLマップの作成
# resource "google_compute_url_map" "default" {
#   name            = "web-url-map"
#   default_service = google_compute_backend_service.default.id
# }

# # HTTPSプロキシの作成
# resource "google_compute_target_https_proxy" "default" {
#   name             = "https-proxy"
#   url_map          = google_compute_url_map.default.id
#   ssl_certificates = [google_compute_managed_ssl_certificate.default.id]
# }

# # グローバルロードバランサー用HTTPSフォワーディングルール
# resource "google_compute_global_forwarding_rule" "https" {
#   name                  = "https-forwarding-rule"
#   target                = google_compute_target_https_proxy.default.id
#   port_range            = "443"
#   ip_address            = google_compute_global_address.lb_ip.address
#   load_balancing_scheme = "EXTERNAL_MANAGED"
# }
