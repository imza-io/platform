---
title: C4 - Container
---

# C4: Container (C4-PlantUML)

Uygulamanın kapsayıcıları, veri depoları ve iletişimleri.

```plantuml
@startuml C4_Container
!include _assets/plantuml/C4_Container.puml

Person(user, "Kullanıcı")
Person(app, "Mobil Uygulama")

System_Boundary(sys, "imza.io Platformu") {
  Container(gw, "API Gateway", "Reverse Proxy", "Edge yönlendirme / SSL")
  Container(api, "Backend API", "ASP.NET", "İşlevsel servisler ve REST")
  Container(rt, "SignalR Hub", "SignalR", "Gerçek zamanlı iletişim")
  Container(worker, "Background Workers", "Worker Service", "Zamanlanmış/arkaplan işler")

  ContainerDb(db, "RDBMS", "SQL", "Kalıcı veriler")
  Container(blob, "Belge Deposu", "Object Storage", "Belgeler ve ekler")
  Container(cache, "Cache", "Redis", "Önbellek")
}

Rel(user, gw, "HTTP(S)")
Rel(app, rt, "WebSocket")
Rel(gw, api, "HTTP")
Rel(api, rt, "WS")
Rel(api, db, "CRUD")
Rel(api, blob, "Belge")
Rel(api, cache, "Cache")
Rel(worker, db, "CRUD")
Rel(worker, blob, "Belge")
@enduml
```

> Not: Dağıtımda Docker Swarm veya ileride K3s hedeflenmektedir.
