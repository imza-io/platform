# Scriptler – Kullanım Rehberi

Bu sayfa `scripts/` klasöründeki komut dosyalarının amacını ve kullanımını özetler. Tüm komutlar depo kökünden çalıştırılmalıdır.

## Observability / Elastic APM
- `scripts/elastic-up.ps1` / `scripts/elastic-up.sh`
  - Elastic APM + OTel Collector yığınını başlatır.
  - Bayraklar: `-Aspire`/`--aspire` (Aspire Dashboard dahil), `-Pull`/`--pull` (imajları güncelleyerek başlatır).
  - Örnek: `./scripts/elastic-up.ps1 -Pull` veya `bash scripts/elastic-up.sh --pull`
- `scripts/elastic-down.ps1` / `scripts/elastic-down.sh`
  - Yığını durdurur; `-Volumes`/`--volumes` ile verileri de siler.
  - Örnek: `./scripts/elastic-down.ps1 -Volumes`
- `scripts/elastic-kibana-provision.ps1` / `scripts/elastic-kibana-provision.sh`
  - Kibana’da Discover için veri görünümleri (`APM Traces`, `APM Metrics`, `APM Logs`) oluşturur.
  - Örnek: `./scripts/elastic-kibana-provision.ps1 -KibanaUrl http://localhost:5601`
- `scripts/elastic-kibana-alerts.ps1` / `scripts/elastic-kibana-alerts.sh`
  - Temel uyarı kuralları ekler (hata sayısı, gecikme). Opsiyonel webhook connector oluşturur.
  - Örnek: `./scripts/elastic-kibana-alerts.ps1 -KibanaUrl http://localhost:5601 -ServiceName Web -WebhookUrl https://hook`

### Örnek Çıktılar

Elastic Up (PowerShell):

```text
Starting Elastic APM stack... (Aspire=False, Pull=True)
Elastic APM stack is up.
```

Kibana Provision (PowerShell):

```text
Kibana provisioning starting... (http://localhost:5601)
Created data view 'APM Traces' (traces-apm*) -> <id>
Created data view 'APM Metrics' (metrics-apm*) -> <id>
Created data view 'APM Logs' (logs-apm*) -> <id>
Default data view set -> <id>
Kibana provisioning completed.
```

### Yaygın Hatalar ve Çözümleri

- Collector port çakışması (4317/4318):
  - Belirti: Collector container’ı başlatılamıyor (ports already allocated).
  - Çözüm: `deploy/observability/elastic/docker-compose.yml` içinde OTLP portları sadece `otel-collector` için host’a açılır; `apm-server`’da 4317/4318 publish edilmemelidir (mevcutta kaldırıldı).
- Kibana hazır değil (provision/alerts script’leri hata):
  - Belirti: `Kibana not ready at http://localhost:5601`.
  - Çözüm: `elastic-up` sonrasında 10–20 saniye bekleyin, script’i tekrar çalıştırın. Port/erişim engeli yoksa kendi kendine düzelir.
- Uygulama metrik/izleri gelmiyor:
  - Kontrol: Serviste `OTEL_EXPORTER_OTLP_ENDPOINT` ve `OTEL_EXPORTER_OTLP_PROTOCOL` doğru mu? AppHost bunları `.env`’den geçirir.
  - Collector health: `http://localhost:13133` ve container loglarına bakın.

## Redis (TLS)
- `scripts/redis-gencerts.ps1`
  - Lokal TLS CA ve Redis için sunucu sertifikalarını üretir (`deploy/redis/tls/`).
- `scripts/redis-import-ca.ps1` / `scripts/redis-import-ca-macos.sh` / `scripts/redis-import-ca-linux.sh`
  - Üretilen CA sertifikasını işletim sistemi güven deposuna ekler.
- `scripts/redis-up.ps1` / `scripts/redis-down.ps1`
  - Redis (TLS) servislerini Docker Compose ile başlatır/durdurur. Port ve parola `deploy/.env` üzerinden gelir.

### Adım Adım – Redis TLS

1) Sertifikaları üretin

```powershell
./scripts/redis-gencerts.ps1
```

2) CA sertifikasını işletim sistemine import edin

- Windows (Kullanıcı deposu):

```powershell
./scripts/redis-import-ca.ps1
```

- Windows (Yerel Bilgisayar – Yönetici):

```powershell
./scripts/redis-import-ca.ps1 -Scope LocalMachine
```

- macOS:

```bash
bash scripts/redis-import-ca-macos.sh
```

- Linux (update-ca-certificates):

```bash
bash scripts/redis-import-ca-linux.sh
```

3) Redis’i başlatın

```powershell
./scripts/redis-up.ps1
```

4) Bağlantıyı test edin (redis-cli ile)

```bash
redis-cli --tls -h localhost -p <REDIS_TLS_PORT> \
  --cacert deploy/redis/tls/ca.crt -a <REDIS_PASSWORD> PING
```

Beklenen cevap: `PONG`

5) Yaygın Sorunlar

- `WRONGPASS invalid username-password pair`:
  - `deploy/.env` içindeki `REDIS_PASSWORD` ile testte kullandığınız parola aynı olmalı.
- Sertifika hataları:
  - `--cacert` yolu doğru mu? Sertifikaları yeniden üretip CA’yı tekrar import edin.
- Port çakışması:
  - `deploy/.env` içindeki `REDIS_TLS_PORT` dolu olabilir; uygun boş bir port seçin.

## PlantUML
- `scripts/plantuml-up.ps1` / `scripts/plantuml-down.ps1`
  - Lokal PlantUML sunucusunu (`http://localhost:8080`) başlatır/durdurur.

## Dokümantasyon
- `scripts/docs-serve.ps1`
  - MkDocs ile dokümanları canlı olarak servis eder (hot-reload).
- `scripts/docs-build.ps1`
  - Dokümanları `site/` klasörüne derler. Gerekli Python paketleri yoksa kurar.
- `scripts/docs-encoding-scan.ps1`
  - UTF‑8 olmayan `.md` dosyalarını tarar; `-Fix -CodePage 1254` ile UTF‑8’e dönüştürebilir.
  - Örnek: `./scripts/docs-encoding-scan.ps1 -Root docs -Fix -CodePage 1254`

### Örnek Çıktı

```text
All files under 'docs' are valid UTF-8.
```

Hata olması halinde UTF‑8’e dönüştürür ve `Fixed: <path>` satırları üretir.

## Yardımcılar
- `scripts/submodules-init.ps1` / `scripts/submodule-add.ps1`
  - Git submodule yönetimi için yardımcı komutlar.
- `scripts/project-docs-new.ps1`
  - Yeni proje dokümantasyonu için iskelet oluşturur.
- `scripts/c4-vendor.ps1`
  - C4 PlantUML şablonlarını projeye kopyalar/günceller.
- `scripts/openssl-install.ps1` / `scripts/openssl-install-macos.sh` / `scripts/openssl-install-linux.sh`
  - OpenSSL kurulumuna yardımcı olur (platforma göre).

## Notlar
- Çoğu script, `deploy/.env` dosyasındaki ayarları kullanır (örn. `COMPOSE_PROJECT_NAME`, `REDIS_*`, `OTEL_*`).
- Windows PowerShell ve Bash sürümleri eşdeğer işlevsellik sağlar; kendi ortamınıza uygun olanı kullanın.
