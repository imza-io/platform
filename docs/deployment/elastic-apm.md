# Elastic APM (Ücretsiz/Basic) On-Prem – Hızlı Başlangıç

Bu yığın, on‑prem için ücretsiz (Basic lisansı) bir Elastic APM kurulumunu içerir:

- Elasticsearch (tek node, güvenlik kapalı — sadece geliştirme için)
- Kibana (güvenlik kapalı — sadece geliştirme için)
- APM Server (OTLP ile trace/metric/log alır)
- OpenTelemetry Collector (uygulamaların giriş noktası; APM Server’a yönlendirir)

Yollar:

- Compose: `deploy/observability/elastic/docker-compose.yml`
- APM Server yapılandırması: `deploy/observability/elastic/apm-server.yml`
- OTel Collector yapılandırması: `deploy/observability/elastic/otel-collector.yaml`

Önemli: Bu konfigürasyon geliştirme için sadeleştirilmiştir. Üretim ortamında xpack güvenliği (TLS + kullanıcılar) açılmalı ve anonim erişim kapatılmalıdır.

## Çalıştırma

1) Yığını başlatın

```bash
docker compose -f deploy/observability/elastic/docker-compose.yml up -d
```

veya depo kökündeki kolay komutları kullanın:

- PowerShell
  - Up: `./scripts/elastic-up.ps1 [-Aspire] [-Pull]`
  - Down: `./scripts/elastic-down.ps1 [-Aspire] [-Volumes]`
- Bash
  - Up: `bash scripts/elastic-up.sh [--aspire] [--pull]`
  - Down: `bash scripts/elastic-down.sh [--aspire] [--volumes]`

2) Arayüzler

- Kibana: `http://localhost:5601`
- APM Intake: `http://localhost:8200`
- OTel Collector (uygulamaların hedefi):
  - gRPC: `http://localhost:4317`
  - HTTP: `http://localhost:4318`
  - Health: `http://localhost:13133` (Collector)

3) Kibana veri görünümlerini oluşturun (Discover deneyimi için önerilir)

- PowerShell (Windows):

```powershell
./scripts/elastic-kibana-provision.ps1 -KibanaUrl http://localhost:5601
```

- Bash (Linux/macOS):

```bash
bash scripts/elastic-kibana-provision.sh http://localhost:5601
```

Bu işlem üç veri görünümü oluşturur: `APM Traces` (`traces-apm*`), `APM Metrics` (`metrics-apm*`) ve `APM Logs` (`logs-apm*`). Varsayılan görünümü `APM Traces` olarak ayarlar. APM/Logs/Metrics uygulamaları bu adım olmadan da çalışır; ancak Discover için faydalıdır.

4) Temel uyarıları (alert) oluşturun (hata sayısı ve gecikme)

- PowerShell (Windows):

```powershell
./scripts/elastic-kibana-alerts.ps1 -KibanaUrl http://localhost:5601 -ServiceName <opsiyonel> -WebhookUrl <opsiyonel>
```

- Bash (Linux/macOS):

```bash
bash scripts/elastic-kibana-alerts.sh http://localhost:5601 <opsiyonel-servis> <opsiyonel-webhook>
```

Varsayılanlar: 5 dakikada >10 hata, gecikme ≥1000ms. Eşikler script parametreleri ile değiştirilebilir. `WebhookUrl` verilmezse kurallar aksiyonsuz oluşturulur; Kibana’dan sonradan aksiyon ekleyebilirsiniz.

E-posta ile uyarı için:

1) Kibana için şifreli kayıt anahtarı (compose içinde dev anahtar eklendi).
2) E-posta connector oluşturun:

```powershell
./scripts/elastic-kibana-email-connector.ps1 -KibanaUrl http://localhost:5601 -Name "SMTP Email" -From no-reply@example.com -Host smtp.example.com -Port 587 -User user -Password pass -To ops@example.com
```

3) Kuralları e-posta connector’üyle oluşturun (PowerShell):

```powershell
./scripts/elastic-kibana-alerts.ps1 -KibanaUrl http://localhost:5601 -ServiceName Web -EmailConnectorId <connector-id> -EmailTo ops@example.com
```

## Uygulama yapılandırması (.NET / Aspire)

Servislerinizi Collector’a yönlendirin (önerilen):

Ortam değişkenleri:

- `OTEL_EXPORTER_OTLP_PROTOCOL=grpc`
- `OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317`
- `OTEL_SERVICE_NAME=<servis-adı>`
- İsteğe bağlı: `OTEL_RESOURCE_ATTRIBUTES=deployment.environment=dev`

Kod (Program.cs) — tipik kurulum:

```csharp
builder.Services.AddOpenTelemetry()
    .ConfigureResource(r => r.AddService(builder.Environment.ApplicationName))
    .WithTracing(t => t
        .AddAspNetCoreInstrumentation()
        .AddHttpClientInstrumentation()
        .AddSqlClientInstrumentation()
        .AddOtlpExporter())
    .WithMetrics(m => m
        .AddAspNetCoreInstrumentation()
        .AddRuntimeInstrumentation()
        .AddOtlpExporter());

builder.Logging.AddOpenTelemetry(o =>
{
    o.IncludeScopes = true;
    o.ParseStateValues = true;
    o.AddOtlpExporter();
});
```

Aspire: Geliştirme için Aspire Dashboard’ı kullanabilirsiniz. `deploy/observability/elastic/docker-compose.override.aspire.yml` ile çalıştırdıktan sonra `otel-collector.yaml` içindeki Aspire exporter’ını (OTLP) yorumdan çıkararak Collector’dan `http://aspire-dashboard:18889` adresine paralel akış verebilirsiniz.

Not: Repo kökündeki `deploy/.env` dosyasına aşağıdaki değişkenleri ekledik; AppHost bu dosyayı da okuyup servis süreçlerine aktarır. Bu sayede ortam değişkenlerini merkezi olarak yönetebilirsiniz.

```
OTEL_EXPORTER_OTLP_PROTOCOL=grpc
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
OTEL_RESOURCE_ATTRIBUTES=deployment.environment=dev
```

## Neler sağlanır

- OTLP ile gelen trace/metric/log verileri APM Server tarafından alınır
- Elasticsearch’te saklanır, Kibana’da (APM, Logs, Metrics) görüntülenir
- Trace-log-metric korelasyonu tek panelde yapılır

## Üretim için sağlamlaştırma

- Elasticsearch ve Kibana’da xpack güvenliği + TLS etkinleştirin
- APM Server için kimlik doğrulama (token) ve TLS yapılandırın
- `apm-server.yml` içinde `anonymous` erişimi kapatın
- Çok düğümlü Elasticsearch, uygun JVM/disk boyutlama, ILM/SLM ayarlayın
- İhtiyaca göre OTel Collector’da Elastic exporter’ı kullanın, filtreleme/örnekleme/redaksiyon ekleyin

İleri konular (ayrı sayfa): `docs/deployment/elastic-retention.md` — ILM/SLM örnekleri ve Collector sampling/redaksiyon yönergeleri.

## Sorun giderme

- İndeksler oluşmuyorsa APM Server loglarını kontrol edin
- Kibana → Observability → APM içinde trafik geldikten sonra servislerin göründüğünü doğrulayın
- Ortam değişkenlerinin Collector’a (4317/4318) işaret ettiğinden emin olun (APM Server’a doğrudan göndermek istemiyorsanız)

## Kaldırma / Sıfırlama

```bash
docker compose -f deploy/observability/elastic/docker-compose.yml down -v
```

Bu komut konteynerleri durdurur ve Elasticsearch veri volume’ünü temizler.
