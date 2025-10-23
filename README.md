# imza.io

![imza.io logo](docs/_assets//images/logo.svg)

## 🚀 Genel Bakış

**imza.io**, bireylerden kurumlara kadar geniş kullanıcı kitlesi için tasarlanmış, sözleşme ve doküman imzalama süreçlerini dijitalleştiren bir platformdur.
Kullanıcılar belgeleri elektronik veya mobil imza ile, hızlı ve güvenli biçimde imzalayabilir.

## 🎯 Proje Amacı

Bu proje, mevcut platform bileşenlerini .NET 10 + Visual Studio 2026 Insiders üzerinde çalışan, SignalR tabanlı gerçek zamanlı mesajlaşma altyapısını modern DevOps bileşenleriyle kurmak, gözlemlenebilir, ölçeklenebilir ve kolay dağıtılabilir bir hale getirmeyi amaçlar.

Sistem, hem geliştirici ortamında (WSL2 + Docker Desktop) hem de üretim ortamında (Docker Swarm veya ileride K3s) aynı şekilde yönetilebilecek bir mimariyi hedeflemektedir.

## 📁 Projeler

| Proje | Açıklama | Doküman |
|-------|----------|---------|

🔗 [imza.io Resmi Sitesi](https://imza.io)

---

## 🧩 Temel Özellikler

- **📱 Mobil ve elektronik imza desteği**
  Belgeler mobil cihazlar veya bilgisayar üzerinden güvenle imzalanabilir.

- **⚙️ Dijital iş akışı yönetimi**
  İmzalama, paraf ve onay süreçleri tek bir ekrandan yönetilir.

- **🔒 Uçtan uca güvenlik**
  5070 Sayılı Elektronik İmza Kanunu’na tam uyumlu altyapı.

- **🔗 Entegrasyon kolaylığı**
  Kurumlar mevcut sistemlerine büyük değişiklik yapmadan imza.io’yu entegre edebilir.

- **🌱 Sürdürülebilirlik**
  Kâğıtsız ofis yaklaşımıyla maliyetleri azaltır, çevreyi korur.

---

## 💡 Değer Önerisi

- Operasyonel verimlilik ve zaman tasarrufu
- Yasal geçerliliği olan güvenli imza altyapısı
- Hızlı kurulum ve kullanıcı dostu arayüz
- Mobil cihazlardan tam erişim
- Kâğıtsız, sürdürülebilir iş süreçleri

---

## 🔧 Kullanım Senaryoları

| Senaryo | Açıklama |
|----------|-----------|
| **Şirket içi imza süreçleri** | Departmanlar arası doküman onayı ve imzası |
| **Kurumlar arası sözleşmeler** | Tedarikçi, bayi, finansal veya hukuki belgelerin dijital imzalanması |
| **Uzaktan imza** | Ofis dışında, mobil cihazlarla imzalama kolaylığı |
| **Onay/Paraf akışları** | Belgelerin birden fazla kişi tarafından paraflanması veya onaylanması |

---

## 🛠️ Teknik Özellikler

- **Platformlar:** Web, Android, iOS, Desktop (Windows/macOS)
- **Kimlik Doğrulama:** e-Devlet, Mobil İmza, e-İmza, OTP
- **Servis Entegrasyonları:**
  - Eposta & SMS Servisleri
  - GSM Operatörleri / MSSP
  - ESHS / OCSP / CRL / TS Servisleri
  - Bulut Depolama Servisleri
- **API Desteği:** RESTful / OpenAPI / JSON
- **Yasal Uyum:** 5070 Sayılı Kanun ve ETSI Standartları

---

## 🧠 Kimler İçin?

- **KOBİ’ler:** İş süreçlerini dijitalleştirmek ve maliyetleri azaltmak isteyen işletmeler
- **Kurumsal Şirketler:** Çok taraflı sözleşme süreçleri yürüten kurumlar
- **Uzaktan Çalışan Ekipler:** Mobil imza ve onay akışına ihtiyaç duyan ekipler

---

## 📲 Uygulamalar

- [imza.io Mobile (Google Play)](https://play.google.com/store/apps/details?id=com.imzaio.mobile)
- [imza.io iOS (App Store)](https://apps.apple.com/tr/app/imza-io/idXXXXXXXX)
*(App Store bağlantısı güncellenecektir)*

---

## 🧰 Meta Repo ve Submodule Yapısı

Bu depo, imza.io platformunun meta reposudur. Ürünlere ait bağımsız repolar bu depo altında `products/<urun-adi>` klasöründe Git Submodule olarak bulunur.

- Klasör yapısı: `products/<urun-adi>` (her ürün ayrı bir submodule)
- Scriptler (Windows/PowerShell):
  - `scripts/submodules-init.ps1` — Tüm submodule’leri initialize ve update eder
  - `scripts/submodule-add.ps1` — Yeni bir ürünü submodule olarak ekler

Kurulum / Klonlama
- İlk klonlama (önerilen): `git clone --recurse-submodules <meta-repo-url>`
- Mevcut klon için: `git submodule update --init --recursive`

Yeni Ürün Ekleme
- Örnek: `git submodule add -b main <repo-url> products/<urun-adi>`
- Dal takibi (isteğe bağlı): `git config -f .gitmodules submodule.products/<urun-adi>.branch main`
- Not: Submodule ekledikten sonra üst repoda `.gitmodules` ve `products/<urun-adi>` değişikliklerini commit etmeyi unutmayın.

Güncelleme
- Tüm alt depoları güncelle: `git submodule foreach --recursive git pull`
- URL değişikliklerini senkronize et: `git submodule sync --recursive`

Kaldırma
- `git submodule deinit -f -- products/<urun-adi>`
- `git rm -f products/<urun-adi>`
- `.gitmodules` dosyasındaki ilgili `submodule.products/<urun-adi>` bölümünü silin ve değişiklikleri commit edin.

Notlar
- Submodule’ler üst repoda belirli bir commit’e sabitlenir; güncelledikten sonra üst repoda da commit gerekir.
- Submodule içine girip (`cd products/<urun-adi>`) kendi remote’una push etmelisiniz; üst repodan submodule içeriği push edilmez.

---

## 📚 Dokümantasyon (MkDocs + C4)

Platform dokümantasyonu `docs/` dizinindedir ve MkDocs (Material teması) ile yayınlanır. C4 diyagramları PlantUML ile render edilir.

- Bağımlılıkları kur (bir kez): `python -m pip install -r docs/requirements.txt`
- Yerel PlantUML sunucusu (önerilir): `./scripts/plantuml-up.ps1` (http://localhost:8080)
- Yerel önizleme (public server): `./scripts/docs-serve.ps1`
- Yerel önizleme (lokal PlantUML): `mkdocs serve -f mkdocs.local.yml`
- Derleme: `./scripts/docs-build.ps1` (çıktı `site/` dizinine alınır)
- Yapılandırma dosyası: `mkdocs.yml`
- Başlangıç sayfası: `docs/index.md`
- C4 diyagramları: `docs/architecture/c4/` (Context/Container/Component/Code)

GitHub Pages Yayını
- Repo Settings → Pages: Source = GitHub Actions
- Workflow: `.github/workflows/docs.yml` push ile otomatik yayınlar (CI içinde PlantUML server başlatılır)
- `mkdocs.yml` içindeki `site_url` değerini kendi repo adresinizle güncelleyin

---

## 📦 Proje Dokümantasyonu ve Release Yönetimi

Proje bazlı dokümantasyon ve sürüm notları `docs/projects/` altında tutulur.

- Yapı: `docs/projects/<proje>/index.md` ve `docs/projects/<proje>/releases/`
- Şablonlar: `docs/projects/_project-template.md`, `docs/projects/_release-template.md`
- Hızlı oluşturma (Windows): `./scripts/project-docs-new.ps1 -Name <proje> -Title "Başlık" -Owner "İsim"`
- MkDocs menüsü: `mkdocs.yml` → `nav` altında “Projeler” bölümüne ilgili yolları ekleyin

Örnek
- Örnek proje sayfası: `docs/projects/sample-project/index.md`
- Örnek release notu: `docs/projects/sample-project/releases/0.1.0.md`

## 🌍 Sürdürülebilirlik ve Gelecek

imza.io, kâğıtsız ofis vizyonuyla çevresel etkiyi azaltmayı hedefler.
Gelecek sürümlerinde, **yapay zekâ destekli belge analizi**, **otomatik iş akışı oluşturma**,
ve **gelişmiş entegrasyon yetenekleri** gibi yenilikler planlanmaktadır.

---

## 🗒️ Değişiklik Günlüğü

Bu bölüm, projede yapılan önemli değişikliklerin kısa özetini içerir. Yeni bir kayıt eklerken aşağıdaki biçimi kullanın:

- YYYY-AA-GG — Kısa başlık: kısa açıklama. [Etiket]
  - Örnek etiketler: [Backend], [Frontend], [DevOps], [Docs], [Security], [Breaking]

Kayıtlar (en yeni en üstte):

- 2025-10-23 — Değişiklik Günlüğü eklendi: README’ye günlüğün formatı ve ilk kayıt eklendi. [Docs]

---

## 📞 İletişim

📧 **info@imza.io**
🌐 [https://imza.io](https://imza.io)
💼 [LinkedIn](https://www.linkedin.com/company/imza-io)

---

> © 2025 imza.io — hızlı, kolay, güvenli
