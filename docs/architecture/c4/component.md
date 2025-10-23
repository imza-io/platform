---
title: C4 - Component
---

# C4: Component (Backend API)

Backend API içindeki temel bileşenler ve bağımlılıklar.

```mermaid
flowchart TB
  subgraph API[Backend API]
    ctrl[Controllers]
    appsvc[Application Services]
    dom[Domain]
    infra[Infrastructure]
  end

  subgraph Integrations[Dış Entegrasyonlar]
    mssp[MSSP]
    eshs[ESHS/OCSP/TS]
    notify[E-posta/SMS]
  end

  ctrl --> appsvc
  appsvc --> dom
  appsvc --> infra
  infra --> mssp
  infra --> eshs
  infra --> notify
```

Prensipler
- Controller’lar ince, iş kuralları domain’de
- Application Services orkestrasyon ve transaction sınırları için
- Infrastructure dış kaynaklara erişim adaptörlerini barındırır

