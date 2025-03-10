# # Cloud DNSゾーンの作成
# resource "google_dns_managed_zone" "example_zone" {
#   name        = "example-zone"
#   dns_name    = "example.com."
#   description = "Example DNS Zone"
# }

# # DNSレコードの作成（Aレコード）
# resource "google_dns_record_set" "a_record" {
#   name         = "www.example.com."
#   managed_zone = google_dns_managed_zone.example_zone.name
#   type         = "A"
#   ttl          = 300

#   # グローバルロードバランサーのIPアドレスを指定
#   rrdatas = [google_compute_global_address.lb_ip.address]
# }
