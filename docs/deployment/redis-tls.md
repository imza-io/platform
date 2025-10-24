# Redis TLS Kurulumu (Yerel Geliştirme)

Bu rehber, yerel ortamda Redis’i TLS (şifreli) çalıştırma, self‑signed CA üretme ve istemcileri güvenli şekilde bağlama adımlarını içerir.

## OpenSSL Kurulumu

Sertifika üretimi için OpenSSL gerekir. Aşağıdaki scriptleri/komutları kullanabilirsiniz.

- Windows: `./scripts/openssl-install.ps1`
  - winget (ShiningLight.OpenSSL.Light) veya Chocolatey (openssl-light) ile kurar.
- macOS: `./scripts/openssl-install-macos.sh`
  - Homebrew ile `openssl@3` kurar; PATH için öneri verir.
- Linux: `./scripts/openssl-install-linux.sh`
  - Dağıtıma göre `openssl` paketini kurar.

Kurulum sonrası doğrulama: `openssl version`

## 1) Sertifikaları Üretin

- Komut: `./scripts/redis-gencerts.ps1`
- Üretilen dosyalar: `deploy/redis/tls/ca.crt`, `ca.key`, `redis.crt`, `redis.key`

> Not: CN=localhost ve SAN olarak `DNS:localhost`, `IP:127.0.0.1` içerir. Yalnızca yerel geliştirme içindir.

## 2) Redis’i TLS ile Başlatın

- Komut: `./scripts/redis-up.ps1`
- Varsayılan TLS portu: `6379` (değiştirmek için `deploy/.env` içindeki `REDIS_TLS_PORT` değerini değiştirin)

## 3) CA Sertifikasını Sisteme Güvenilir Olarak Ekleyin

Sertifika zinciri doğrulaması için istemcilerin `deploy/redis/tls/ca.crt` dosyasını güvenilir bir kök olarak tanıması gerekir.

### Windows

- PowerShell (Yönetici):
  - Current User: `Import-Certificate -FilePath .\deploy\redis\tls\ca.crt -CertStoreLocation Cert:\CurrentUser\Root`
  - Local Machine: `Import-Certificate -FilePath .\deploy\redis\tls\ca.crt -CertStoreLocation Cert:\LocalMachine\Root`
- Alternatif: `certmgr.msc` ile “Trusted Root Certification Authorities” altına `ca.crt` içe aktarın.

### macOS

- Script ile: `./scripts/redis-import-ca-macos.sh`
- Manuel (Terminal, sudo): `sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain deploy/redis/tls/ca.crt`
- Alternatif: Keychain Access ile System keychain altına `ca.crt` dosyasını ekleyin ve “Always Trust” seçin.

### Linux

- Script ile (otomatik algılama): `./scripts/redis-import-ca-linux.sh`
- Manuel:
  - Debian/Ubuntu:
    - `sudo cp deploy/redis/tls/ca.crt /usr/local/share/ca-certificates/redis-ca.crt`
    - `sudo update-ca-certificates`
  - RHEL/CentOS/Fedora:
    - `sudo cp deploy/redis/tls/ca.crt /etc/pki/ca-trust/source/anchors/redis-ca.crt`
    - `sudo update-ca-trust`

> WSL kullanıyorsanız, ilgili Linux dağıtımında da CA’yı yukarıdaki Linux adımlarıyla ekleyin.

## 4) Bağlantı Testi (redis-cli)

`deploy/.env` içindeki `REDIS_PASSWORD` değerini kullanın.

```
redis-cli --tls -h localhost -p 6379 \
  --cacert deploy/redis/tls/ca.crt \
  -a <PAROLA> PING
```

Başarılı yanıt: `PONG`

## 5) .NET İstemci Örnekleri

### StackExchange.Redis

- Connection string:
  - `localhost:6379,ssl=True,sslHost=localhost,password=<PAROLA>,abortConnect=False`
- Kod:
```
using StackExchange.Redis;

var options = ConfigurationOptions.Parse("localhost:6379");
options.Ssl = true;
options.SslHost = "localhost"; // CN/SAN ile eşleşmeli
options.Password = "<PAROLA>";
options.AbortOnConnectFail = false;
var mux = await ConnectionMultiplexer.ConnectAsync(options);
```

> Not: CA güvenilir değilse bağlanma sırasında sertifika doğrulama hatası alırsınız. CA’yı güvenilir olarak ekleyin.

### ServiceStack.Redis

```
using ServiceStack.Redis;

// rediss:// şeması TLS anlamına gelir
using var manager = new RedisManagerPool("rediss://:<PAROLA>@localhost:6379");
using var client = manager.GetClient();
client.Ping();
```

## Sorun Giderme

- `SSL certificate verify failed`:
  - CA’yı güvenilir köklere eklediğinizden emin olun.
  - Host adı eşleşmesi: `sslHost=localhost` kullanın ve sertifikada CN/SAN `localhost` olduğundan emin olun.
- Bağlantı kurulamadı:
  - `./scripts/redis-up.ps1` TLS sertifika dosyalarının varlığını kontrol eder; eksikse `./scripts/redis-gencerts.ps1` çalıştırın.
  - Port çakışması için `REDIS_TLS_PORT` değerini değiştirin.
