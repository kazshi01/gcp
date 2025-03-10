# # マネージドSSL証明書の作成
# resource "google_compute_managed_ssl_certificate" "default" {
#   name = "example-cert"
  
#   managed {
#     domains = ["www.example.com"]
#   }
  
#   # マネージドSSL証明書はGCPが自動的に証明書の取得と更新を行います
#   # Let's Encryptを使用して証明書が発行されます
#   # DNSレコードが正しく設定されていることを確認してください
# }
