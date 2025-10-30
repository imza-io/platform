---
title: SignGate – Dağıtım ve Kurulum
---

# Dağıtım ve Kurulum

Bu sayfa SignGate'i bileşenleriyle birlikte çalıştırmak için gereken önkoşulları ve temel kurulum adımlarını özetler.

## Önkoşullar
- .NET 8 SDK (API/EasyHub/TaskScheduler)
- Java 17+ ve Maven (Validator)
- Veritabanı (EsigDB), Nesne Deposu (belge deposu), Redis (cache)

## Konfigürasyon
- API/EasyHub/TaskScheduler: `appsettings.*.json` ve ortam değişkenleri
- Validator: `application.properties` (deployment'ta harici klasör önerilir)

## Sağlık ve İzleme
- API/EasyHub/TaskScheduler: uygulama health endpoint’leri (örn. `/health`)
- Validator: `GET /actuator/health` 200 → sağlıklı
- Log/metric/trace entegrasyonları (platform standardına uygun)

## Notlar
- QR ekleme gibi özellikler için harici Image servisi gerekebilir
- Sertifika OCSP/CRL adreslerinin işlenmesi için TaskScheduler görevi tanımlayın

## Observability (Elastic APM + OpenTelemetry)
- Kurulum ve kullanım: `docs/deployment/elastic-apm.md`
- Hızlı başlatma:
  - Elastic stack: `./scripts/elastic-up.ps1 -Pull` (Windows) veya `bash scripts/elastic-up.sh --pull`
  - SignGate (AppHost): çözümü çalıştırın (SignGate.AppHost). AppHost servisler için `OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317` ve `OTEL_EXPORTER_OTLP_PROTOCOL=grpc` geçirir.
  - Kibana: `http://localhost:5601` üzerinden APM/Logs/Metrics görünümlerini kullanın.
