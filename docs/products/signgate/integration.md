---
title: SignGate — Entegrasyon Kılavuzu
---

# Entegrasyon Kılavuzu

Bu kılavuz, SignGate API’si ile temel imzalama/doğrulama akışlarının entegrasyonunu özetler.

## Önkoşullar
- API erişimi ve kimlik doğrulama bilgileri
- Ortam adresleri (dev/test/uat/prod)

## Tipik Akışlar
- CAdES/PAdES/XAdES imzalama
- Mobil imza (MSSP) ile imzalama
- Doğrulama (OCSP/CRL/TS)

## API Örnekleri (Yer Tutucu)
- POST `/api/sign/cades`
  - İstek gövdesi: belge özeti, imzacı bilgileri, zaman damgası isteği
  - Yanıt: imza oturumu / imza verisi

- POST `/api/validate`
  - İstek: imza belgesi veya referans
  - Yanıt: doğrulama sonucu ve ayrıntılar

Not: Gerçek uç noktalar ve sözleşme şemaları ilgili ürün sürümüne göre değişebilir. Ayrıntılı referans için ürün API dokümanına bakın.

## Callback ve Bildirimler
- Uzun süren imza akışlarında callback URL yapılandırması
- E‑posta/SMS bildirimleri

## Güvenlik ve Oransal Kullanım
- Oran sınırlama (rate limit) ve API anahtarı kapsamları
- İmza verilerinin güvenli taşınması (TLS) ve log redaksiyonu

