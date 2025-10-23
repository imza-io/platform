---
title: C4 - Container
---

# C4: Container

Uygulamanın çalıştığı kapsayıcıları, veri depolarını ve iletişimlerini gösterir.

```mermaid
flowchart LR
  subgraph Client[İstemci]
    web[Web UI]
    app[Mobile App]
  end

  subgraph Edge[Edge / API Gateway]
    gw[API Gateway]
  end

  subgraph Core[Core Services]
    api[Backend API (ASP.NET)]
    rt[SignalR Hub]
    worker[Background Workers]
  end

  subgraph Data[Veri Katmanı]
    db[(RDBMS)]
    blob[(Belge Deposu)]
    cache[(Cache / Redis)]
  end

  Client -->|HTTP(S)| gw --> api
  Client -->|WebSocket| rt
  api --> rt
  api -->|CRUD| db
  api -->|Belge| blob
  api -->|Cache| cache
  worker --> db
  worker --> blob
```

> Not: Dağıtımda Docker Swarm veya ileride K3s hedeflenmektedir.

