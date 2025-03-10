output "load_balancer_ip" {
  description = "ロードバランサーのグローバルIPアドレス"
  value       = google_compute_global_address.lb_ip.address
}

output "cloud_run_url" {
  description = "Cloud RunサービスのURL"
  value       = google_cloud_run_v2_service.default.uri
} 
