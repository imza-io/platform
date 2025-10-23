---
title: Mimari Genel Bakış
---

# Mimari Genel Bakış

Bu bölüm, imza.io platformunun üst düzey mimarisini açıklar. C4 yaklaşımı ile dört seviyede ele alınır:

1) Context: Dış aktörler ve komşu sistemlerle ilişkiler
2) Container: Uygulama kapsayıcıları ve veri depoları
3) Component: Servislerin içindeki mantıksal bileşenler
4) Code: Örnek sınıf/katman ilişkileri

> Not: Diyagramlar Mermaid ile ifade edilir ve tarayıcıda render edilir.

## Mimari İlkeler

- Güvenlik önce gelir (Zero Trust yaklaşımı, güçlü kimlik doğrulama)
- Gözlemlenebilirlik (log/metric/trace) ve otomasyon
- Yatay ölçeklenebilirlik ve bağımsız dağıtım
- Sözleşme-öncelikli API tasarımı (OpenAPI)

