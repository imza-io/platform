---
title: SignGate — API Referansı
---

# API Referansı

Bu sayfa, SignGate ile entegrasyon için temel uç noktaları ve örnekleri özetler. Detaylı şema için OpenAPI dosyasını kullanmanız önerilir.

## Temel Bilgiler
- Base URL (örnek):
  - Dev: https://dev.example.com
  - Test: https://test.example.com
  - Prod: https://api.example.com
- Kimlik Doğrulama: Bearer Token (OAuth2 / API Key kurulumunuza bağlı)
- İçerik Tipi: application/json

## İmzalama

POST `/api/sign/cades`
- Amaç: CAdES imzası üretmek için oturum başlatma veya imzalama
- Örnek istek
```json
{
  "documentHash": "base64(SHA256)",
  "signer": { "id": "TCKN/UUID", "method": "mobile|eimza" },
  "timestamp": true,
  "metadata": { "requestId": "..." }
}
```

## Doğrulama

POST `/api/validate`
- Amaç: İmza doğrulaması (OCSP/CRL/TS)
- Örnek istek
```json
{
  "document": "base64(PDF|ASiC|CMS)",
  "policies": ["etsi-cades", "etsi-pades"],
  "detail": true
}
```

## Hata Modeli (Örnek)
```json
{
  "error": {
    "code": "VALIDATION_FAILED",
    "message": "OCSP yanıtı geçersiz",
    "traceId": "00-..."
  }
}
```

## OpenAPI (Öneri)
- OpenAPI şemasını `docs/products/signgate/openapi/signgate.yaml` yoluna ekleyin.
- İnteraktif dokümantasyon için aşağıdaki seçeneklerden birini tercih edin (opsiyonel):
  1) ReDoc (CDN ile): Bu sayfaya HTML blok olarak ekleyebilirsiniz:
  ```html
  <redoc spec-url="openapi/signgate.yaml"></redoc>
  <script src="https://cdn.redoc.ly/redoc/latest/bundles/redoc.standalone.js"></script>
  ```
  2) Swagger UI (CDN ile):
  ```html
  <div id="swagger"></div>
  <link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist/swagger-ui.css" />
  <script src="https://unpkg.com/swagger-ui-dist/swagger-ui-bundle.js"></script>
  <script>
    window.onload = () => {
      window.ui = SwaggerUIBundle({ url: 'openapi/signgate.yaml', dom_id: '#swagger' });
    }
  </script>
  ```

Not: CDN erişimi gerektirir. Tamamen offline kurulum için MkDocs eklentileri (örn. swagger-ui-tag) eklenebilir.

