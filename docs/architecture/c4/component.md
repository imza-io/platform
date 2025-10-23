---
title: C4 - Component
---

# C4: Component (Backend API, C4-PlantUML)

Backend API içindeki temel bileşenler ve bağımlılıklar.

```plantuml
@startuml C4_Component
!include _assets/plantuml/C4_Component.puml

Container(api, "Backend API", "ASP.NET")

Component(ctrl, "Controllers", "HTTP endpoints")
Component(appsvc, "Application Services", "Use-case orkestrasyonu")
Component(dom, "Domain", "İş kuralları")
Component(infra, "Infrastructure", "Dış kaynak adaptörleri")

Component_Ext(mssp, "MSSP", "Mobil imza sağlayıcıları")
Component_Ext(eshs, "ESHS/OCSP/TS", "Doğrulama/Zaman damgası")
Component_Ext(notify, "E‑posta/SMS", "Bildirim")

Rel(ctrl, appsvc, "Çağrı")
Rel(appsvc, dom, "İş kuralları")
Rel(appsvc, infra, "Adaptörler")
Rel(infra, mssp, "Mobil imza")
Rel(infra, eshs, "OCSP/CRL/TS")
Rel(infra, notify, "Bildirim")
@enduml
```

Prensipler
- Controller’lar ince, iş kuralları domain’de
- Application Services orkestrasyon ve transaction sınırları için
- Infrastructure dış kaynaklara erişim adaptörlerini barındırır
