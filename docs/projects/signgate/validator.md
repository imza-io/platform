---
title: Validator Kurulumu
---

# Validator Kurulumu ve Çalıştırma

SignGate’in doğrulama bileşeni Java ile yazılmıştır ve Maven kullanır. Servis bağımsız çalıştırılabilir veya Windows Service olarak kurulabilir.

## Önkoşullar
- Java (öneri: Temurin/OpenJDK 17+)
- Maven
- Yerel Maven repository proxy (reposilite) jar’ı: `Validator/esig-validator/mvnrepo/reposilite-3.5.0-all.jar`
- Maven `settings.xml` içinde bu repository için gerekli kimlik bilgileri

## Çalıştırma (Geliştirici Modu)
1) Reposilite jar’ı başlatın:
   - `java -jar Validator/esig-validator/mvnrepo/reposilite-3.5.0-all.jar`
   - Maven indirmeleri için proxy/repo olarak çalışır.
2) Uygulamayı derleyin/çalıştırın (örn. Maven ile):
   - `cd Validator` ve `mvn clean package`
   - Üretilen jar dosyasını çalıştırın: `java -Xmx256m -jar esig-validator.jar`

Konfigürasyon
- Yerel config: `Validator/src/main/resources/application.properties`
- Dağıtımta harici config klasörü kullanımı önerilir (örn. jar’ın yanında `config/`):
  - `application.properties` dosyasını bu klasöre taşıyın ve değerleri ortama göre düzenleyin

Sağlık kontrolü
- `GET /actuator/health` 200 dönerse servis sağlıklıdır

## Windows Service (winsw) ile Kurulum
1) WinSW indir: `https://repo.jenkins-ci.org/releases/com/sun/winsw/winsw/` (en güncel sürüm)
2) İndirilen exe’nin adını jar ile aynı yapın (örn. `esig-validator.exe`)
3) İndirilen xml’in adını da jar ile aynı yapın (örn. `esig-validator.xml`)
4) `esig-validator.jar`, `esig-validator.exe`, `esig-validator.xml` aynı klasöre konur
5) `esig-validator.xml` düzenleyin:
   - `<id>esig-validator</id>` ve `<name>ESig Validator</name>` gibi temel alanlar
   - `<arguments>-Xmx256m -jar "%BASE%\esig-validator.jar"</arguments>`
   - `<logpath>%BASE%\logs</logpath>` (önerilir)
6) Yönetici komut satırında klasöre gidin ve kurun:
   - `esig-validator.exe install`
7) Konfigürasyon dosyalarını harici klasöre koyun (ör. `C:\ESigConfig` veya jar yanındaki `config/`)
8) Servisi başlatın ve `http://localhost:<port>/actuator/health` ile doğrulayın

## Notlar ve İpuçları
- `settings.xml` içine custom repository bilgisi/kimlik bilgisi eklemeyi unutmayın
- Log dizini ve rotation stratejisi tanımlayın (winsw ile kolay)
- Üretim ortamında JVM bellek parametrelerini izleyin (`-Xms`, `-Xmx`)

