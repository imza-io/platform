# Elastic APM – Saklama (ILM/SLM) ve Sampling Örnekleri

Bu sayfa üretim ortamı için veri saklama ve sampling örnekleri içerir.

## ILM (Index Lifecycle Management) – Örnek Politika

APM veri akışları (data streams): `traces-apm*`, `metrics-apm*`, `logs-apm*`.

Örnek hedef: 7 gün sakla, sonrasında sil.

Kibana Dev Tools (Console) üzerinden çalıştırın:

```json
PUT _ilm/policy/apm-hot-delete-7d
{
  "policy": {
    "phases": {
      "hot": {
        "actions": {
          "rollover": { "max_age": "1d", "max_size": "50gb" }
        }
      },
      "delete": {
        "min_age": "7d",
        "actions": { "delete": {} }
      }
    }
  }
}
```

Politikayı data stream template’lerine bağlama (örnek – traces):

```json
PUT _index_template/apm-traces-template
{
  "index_patterns": ["traces-apm*"],
  "data_stream": {},
  "template": {
    "settings": {
      "index.lifecycle.name": "apm-hot-delete-7d"
    }
  },
  "priority": 501
}
```

Aynı işlemi metrics ve logs için de (pattern ve template adı değişerek) uygulayın.

Not: Elastic APM varsayılan şablonlarıyla gelebilir. Kendi template’inizi daha yüksek `priority` ile ekleyerek geçersiz kılabilirsiniz.

## SLM (Snapshot Lifecycle Management) – Örnek

Yedekleme gerekiyorsa bir snapshot repository tanımlayın (örn. paylaşılan bir dizin):

```json
PUT _snapshot/apm-repo
{
  "type": "fs",
  "settings": { "location": "/snapshots" }
}
```

Haftalık snapshot politikası:

```json
PUT _slm/policy/weekly-apm
{
  "schedule": "0 30 1 ? * SUN", 
  "name": "<weekly-apm-{now/d}>",
  "repository": "apm-repo",
  "config": { "indices": ["traces-apm*","metrics-apm*","logs-apm*"] },
  "retention": { "expire_after": "30d", "min_count": 1, "max_count": 20 }
}
```

Docker ile kullanıyorsanız Elasticsearch konteynerine `/snapshots` bind mount vermeyi unutmayın.

## Collector – Sampling ve Redaksiyon

`deploy/observability/elastic/otel-collector.yaml` içinde örnek işlemciler (yorumlu) eklenmiştir:

- `probabilistic_sampler`: İzlerin yüzdeye göre örneklenmesi (örn. %10)
- `attributes` (redact): Hassas alanların loglardan temizlenmesi (örn. `authorization` başlığı, `db.statement`)

Etkinleştirmek için:

1) `processors` altında ilgili blokların yorumunu kaldırın.
2) `service.pipelines.traces.processors` içinde `probabilistic_sampler`’ı `batch` öncesine ekleyin.
3) `service.pipelines.logs.processors` içinde `attributes/redact`’i `batch` öncesine ekleyin.

Örnek (traces):

```yaml
service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [probabilistic_sampler, batch]
      exporters: [otlp/elastic-grpc]
```

Uyarı: Sampling veri kaybına yol açar; uyarı kurallarınızı sampling’e uygun yeniden kalibre edin.

