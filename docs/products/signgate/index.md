---
title: SignGate — Ürün Dokümantasyonu
---

# SignGate — Ürün Dokümantasyonu

SignGate, imza.io platformunun imza geçidi ürünüdür. Elektronik/mobil imza süreçlerini, doğrulama (OCSP/CRL/TS) ve sertifika yönetimiyle birlikte güvenli ve izlenebilir şekilde sunar.

## Değer Önerisi
- ETSI uyumlu imza standartları (CAdES / PAdES / XAdES)
- Mobil imza ve e‑İmza akışları için uçtan uca çözüm
- Yüksek erişilebilirlik, gözlemlenebilirlik ve güvenlik
- Entegrasyon kolaylığı (REST API)

## Ana Özellikler
- Çoklu imza formatı ve doğrulama desteği (OCSP/CRL/TS)
- Easy akışları için orkestrasyon (EasyHub)
- İmza doğrulama servisi (Validator, Java)
- Zamanlanmış işler (TaskScheduler)
- Güncelleme servisi (UpdateService)

## Kullanım Senaryoları
- Kurum içi/on‑prem sözleşme ve doküman imzalama
- Kurumlar arası sözleşme ve formların dijital imzalanması
- Uzaktan/mobil imza akışları

## Ürün Bileşenleri (Özet)
- Gateway/API (ASP.NET)
- EasyHub (Orkestrasyon)
- Validator (Java + Maven)
- TaskScheduler (Zamanlanmış işler)
- EsigDB (Veritabanı), belge deposu ve önbellek

## İlgili Sayfalar
- Mimarî (C4): [products/signgate/architecture.md](architecture.md)
- Entegrasyon Kılavuzu: [products/signgate/integration.md](integration.md)
- Dağıtım ve Kurulum: [products/signgate/deployment.md](deployment.md)
- Proje dokümantasyonu ve sürümler: [projects/signgate](../../projects/signgate/index.md)

