---
title: SignGate — Dağıtım ve Kurulum
---

# Dağıtım ve Kurulum

Bu sayfa SignGate’i bileşenleriyle birlikte çalıştırmak için gereken önkoşullar ve temel kurulum adımlarını özetler.

## Önkoşullar
- .NET (API/EasyHub/TaskScheduler)
- Java 17+ ve Maven (Validator)
- RDBMS (EsigDB), Object Storage (belge deposu), Redis (cache)

## Konfigürasyon
- API/EasyHub/TaskScheduler: `appsettings.*.json` ve ortam değişkenleri
- Validator: `application.properties` (deployment’ta harici klasör önerilir)

## Sağlık ve İzleme
- API/EasyHub/TaskScheduler: uygulama health endpoint’leri (örn. `/health`)
- Validator: `GET /actuator/health` 200 → sağlıklı
- Log/metric/trace entegrasyonları (platform standardına uygun)

## Notlar
- QR ekleme gibi özellikler için harici Image servisi gerekebilir
- Sertifika OCSP/CRL adreslerinin işlenmesi için TaskScheduler görevi tanımlayın

Gelişmiş dağıtım ve CI/CD için proje dokümantasyonuna ve ürün repolarındaki pipeline dosyalarına bakın.

