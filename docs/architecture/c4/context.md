---
title: C4 - Context
---

# C4: System Context (C4-PlantUML)

imza.io platformunun dış kullanıcılar ve komşu sistemlerle etkileşimini gösterir.

```plantuml
@startuml C4_Context
!include _assets/plantuml/C4_Context.puml

Person(user, "Kullanıcı", "Birey/Kurum kullanıcılar")
Person(admin, "Yönetici", "Yönetim ve operasyon")

System_Boundary(imzaio, "imza.io Platformu") {
  System_Ext(portal, "Web Portal")
  System_Ext(mobile, "Mobil Uygulamalar")
  System(api, "Backend API")
}

System_Ext(edevlet, "e‑Devlet")
System_Ext(mssp, "MSSP / GSM Operatörleri")
System_Ext(eshs, "ESHS / Zaman Damgası / OCSP")
System_Ext(mail, "E‑posta / SMS Servisleri")

Rel(user, portal, "Belgeleri görüntüle / imzala")
Rel(user, mobile, "Mobil imza")
Rel(admin, portal, "Yönetim")

Rel(portal, api, "HTTP")
Rel(mobile, api, "HTTP")

Rel(api, edevlet, "Kimlik doğrulama")
Rel(api, mssp, "İmza işlemleri")
Rel(api, eshs, "OCSP/CRL/TS")
Rel(api, mail, "Bildirim")
@enduml
```
