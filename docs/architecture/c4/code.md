---
title: C4 - Code
---

# C4: Code (Örnek)

Bu seviye, belirli bir bileşenin (ör. Belge İmzalama) örnek sınıf diyagramını temsil eder.

```mermaid
classDiagram
  class SigningService {
    +Sign(documentId, signerId)
    -validateSigner()
    -applySignature()
  }

  class SignatureProvider {
    +Sign(content, cert)
  }

  class DocumentRepository {
    +GetById(id)
    +Save(document)
  }

  SigningService --> DocumentRepository
  SigningService --> SignatureProvider
```

> Not: Bu diyagram örnektir; gerçek sınıf ve metodlar proje ilerledikçe güncellenecektir.

