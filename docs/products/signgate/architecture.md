---
title: SignGate — Mimarî (C4)
---

# Mimarî (C4)

Bu sayfa SignGate için C4 yaklaşımıyla konteyner ve bileşen görünümünü özetler.

## Container Diyagramı

```plantuml
@startuml C4_Container_SignGate
!include _assets/plantuml/C4_Container.puml

Person(user, "Uygulamalar/Kullanıcılar")
System_Boundary(signgate, "SignGate") {
  Container(api, "Gateway/API", "ASP.NET", "İmza ve doğrulama uçları")
  Container(easy, "EasyHub", "Service", "Easy imza akışları")
  Container(val, "Validator", "Java", "İmza doğrulama")
  Container(jobs, "TaskScheduler", "Service", "Zamanlanmış işler")
  ContainerDb(db, "EsigDB", "SQL", "Kalıcı veriler")
  Container(store, "Belge Deposu", "Object Storage", "Belgeler")
  Container(cache, "Cache", "Redis", "Önbellek")
}

Rel(user, api, "HTTP(S)")
Rel(api, easy, "HTTP")
Rel(api, db, "CRUD")
Rel(api, store, "Belge")
Rel(api, cache, "Cache")
Rel(easy, val, "Doğrulama")
Rel(jobs, db, "CRUD")
@enduml
```

## Component Diyagramı (API)

```plantuml
@startuml C4_Component_SignGate
!include _assets/plantuml/C4_Component.puml

Container(api, "Gateway/API", "ASP.NET")
Component(ctrl, "Controllers", "HTTP Endpoints")
Component(appsvc, "Application Services", "Use‑case orkestrasyonu")
Component(dom, "Domain", "İş kuralları")
Component(infra, "Infrastructure", "Dış sistem adaptörleri")

Rel(ctrl, appsvc, "Çağrı")
Rel(appsvc, dom, "İş kuralları")
Rel(appsvc, infra, "Adaptörler")
@enduml
```

Detaylı platform mimarisi için: Mimari → C4 Modeli sayfalarına bakın.

