---
name: ceo-nakit-akis
description: "Nakit Akış Komuta Merkezi — banka hesapları, tahsilat takibi, nakit projeksiyonu."
version: 1.0.0
author: CEO Asistanı
platforms: [linux]
metadata:
  target: turkish-sme-ceo
  tools: [terminal, file, web_search]
---

# Nakit Akış Komuta Merkezi

CEO'nun en kritik sorusu: "Ne kadar paramız var ve ne zaman gelecek?"

## Tetikleyiciler

- CEO "nakit durum", "tahsilat", "banka" dediğinde
- Her saat başı otomatik güncelleme (cron)
- Yeni banka hareketi geldiğinde (webhook/API)

## Workflow

### 1. Anlık Nakit Pozisyonu

1. Tüm banka hesaplarından (Composio banka API connector) bakiye çek
2. Döviz hesaplarını TL'ye çevir (güncel kur)
3. Toplam bakiyeyi hesapla
4. `vault/template/finans/nakit-pozisyonu.md` güncelle
5. Dashboard'u yenile

### 2. Tahsilat Takibi

1. Açık faturaları tara (e-fatura / muhasebe yazılımı)
2. Vade tarihi geçenleri "gecikmiş" olarak işaretle
3. Her gecikmiş tahsilat için:
   - Kaç gün gecikti?
   - Son iletişim ne zaman?
   - Hatırlatma gönderildi mi?
4. `vault/template/finans/tahsilat.md` güncelle

### 3. Nakit Akış Projeksiyonu

1. Gelecek 30 günlük beklenen giriş/çıkışları hesapla:
   - Girişler: vadesi gelecek faturalar
   - Çıkışlar: maaş, kira, tedarikçi ödemeleri, vergi, SGK
2. `vault/template/finans/nakit-akisi.md` güncelle
3. Nakit sıkışıklığı öngörülüyorsa CEO'yu uyar

### 4. Periyodik Rapor (her sabah)

CEO'ya WhatsApp'tan:
```
💰 Nakit: ₺2.847.000 (3 hesap)
📥 Tahsilat bekleyen: ₺1.230.000 (7 gecikmiş)
📊 Bu ay nakit akış: +₺412.000
⚠ XYZ İnşaat — 620K TL, 12 gün gecikti
```

## Vault Veri Formatı

### nakit-pozisyonu.md
```markdown
bakiye: 2847000
trend: +12
hesap_sayisi: 3
```

### tahsilat.md
```markdown
toplam: 1230000
gecikmis_sayisi: 7
acik_fatura: 23
## Gecikmiş Tahsilatlar
- TAHILAT: MÜŞTERİ — TUTAR, GÜN gün gecikti. AÇIKLAMA
```

### nakit-akisi.md
```markdown
net: +412000
giris: 1840000
cikis: 1428000
projeksiyon: +680000
```

## Banka API Entegrasyonu

Composio MCP üzerinden Garanti BBVA, İş Bankası, Akbank API'leri.
Her banka için ayrı connector konfigürasyonu gerekebilir.

KV Router üzerinden inference yapılır (finansal veri hassas).

## Pitfalls

- Banka API'leri rate-limit yapabilir → sadece saatte bir sorgula
- Döviz kuru gün içinde değişir → son TCMB kuru kullan
- E-fatura entegrasyonu yoksa manuel giriş gerekir
- Hafta sonu banka hareketi olmaz → "son iş günü" verisi göster
