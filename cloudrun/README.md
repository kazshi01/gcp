## Cloud Run アクセス制限

Cloud Runサービスは、セキュリティ強化のため以下の設定によりアクセスが制限されています：

- `ingress = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"` 設定により、ロードバランサーと内部トラフィックからのアクセスのみを許可
- Network Endpoint Group (NEG) を使用してロードバランサーからCloud Runへの接続を構成
- 直接のパブリックアクセスは無効化されており、すべてのトラフィックはロードバランサーを経由

この構成により、Cloud Runサービスへのアクセスを制御し、不正アクセスのリスクを低減しています。

### IAMポリシーについて

Terraformコードでは`allUsers`に`roles/run.invoker`ロールを付与していますが、これは`ingress = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"`設定と組み合わせて機能します：

- `allUsers`に`run.invoker`ロールを付与することで、認証なしでのサービス呼び出しを許可
- しかし、`INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER`設定により、実際のアクセスはロードバランサーと内部トラフィックのみに制限
- 結果として、一般ユーザーは直接Cloud Runにアクセスできず、ロードバランサーを経由する必要がある

この組み合わせにより、認証の複雑さを回避しつつ、アクセス経路を制限してセキュリティを確保しています。 
