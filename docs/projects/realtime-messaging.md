# SignalR Tabanlı Gerçek Zamanlı Mesajlaşma

## Genel Bakış

Bu proje, imza.io platformundaki mevcut modülleri SignalR destekli gerçek zamanlı mesajlaşma altyapısı ile genişletmeyi hedefler. Çözüm, .NET 10 ve Visual Studio 2026 Insiders kullanılarak geliştirilir.

## Hedefler

- .NET 10 üzerinde çalışan, düşük gecikmeli ve yatay ölçeklenebilir bir SignalR katmanı sağlamak.
- Geliştirici ortamında (WSL2 + Docker Desktop) ve üretimde (Docker Swarm, daha sonra K3s) eşleşen dağıtımlar oluşturmak.
- Observability bileşenleri (loglama, metrik, tracing) ile sistemin görünürlüğünü artırmak.
- Modern CI/CD boru hattı ile otomatik test, güvenlik taraması ve dağıtım süreçlerini yönetmek.

## Temel Bileşenler

- **Uygulama:** .NET 10, C#, SignalR
- **Gerçek Zamanlı İletişim:** SignalR hub, persistent connections, backplane (Redis veya Azure SignalR Service değerlendirmesi)
- **Veri Katmanı:** Gerekli durum/mesaj kuyruğu bileşenleri (Redis, RabbitMQ vb.)
- **Altyapı ve Dağıtım:** Docker tabanlı container imajları, Docker Compose (geliştirme), Docker Swarm/K3s (üretim)
- **Observability:** OpenTelemetry, Prometheus/Grafana, merkezi loglama
- **DevOps:** Git tabanlı akış, CI/CD (GitHub Actions/GitLab CI), IaC (Terraform/Ansible opsiyonel)

## Durum

- [x] Proje kapsamının belirlenmesi  
- [ ] Mimari dokümantasyonun oluşturulması  
- [ ] Prototip SignalR hub geliştirmesi  
- [ ] CI/CD pipeline tasarımı  
- [ ] Üretim ortamı topolojisinin netleştirilmesi  

## Kaynaklar

- [.NET SignalR Dokümantasyonu](https://learn.microsoft.com/aspnet/core/signalr/introduction)
- [Docker Resmi Belgeleri](https://docs.docker.com/)
- [OpenTelemetry](https://opentelemetry.io/)

