---
name: ceo-evrak-istihbarati
description: "Evrak İstihbaratı — e-fatura/e-arşiv parse, sözleşme inceleme, risk flag'leme."
version: 1.0.0
author: CEO Asistanı
platforms: [linux]
metadata:
  target: turkish-sme-ceo
  tools: [terminal, file, web_search, web_extract]
---

# Evrak İstihbaratı

Gelen her evrakı analiz eder, özetler, riskleri işaretler. CEO'nun her
sözleşmeyi satır satır okumasına gerek kalmaz.

## Tetikleyiciler

- CEO bir PDF/DOCX/XML paylaştığında
- E-fatura/e-arşiv geldiğinde (email/webhook)
- CEO "şu sözleşmeyi incele" dediğinde

## Workflow

### 1. E-fatura / E-arşiv Analizi

1. XML/Pdf'ten fatura bilgilerini çıkar:
   - Fatura no, tarih, tutar, KDV
   - Alıcı/satıcı bilgileri
   - Kalem detayları
2. Muhasebe kayıtlarıyla eşleştir (varsa)
3. Anormallik kontrolü:
   - Tutar beklenenden farklı mı?
   - KDV oranı doğru mu?
   - Mükerrer fatura mı?
4. CEO'ya sadece anormal olanları bildir

### 2. Sözleşme İnceleme

1. Sözleşmeyi oku (PDF → text)
2. Kritik maddeleri çıkar:
   - Toplam bedel ve ödeme planı
   - Teslim tarihi ve cezai şartlar
   - Fesih koşulları
   - Garanti süreleri
   - İhtilaflı maddeler
3. Risk değerlendirmesi yap:
   - 🔴 Yüksek risk: tek taraflı fesih hakkı, aşırı cezai şart
   - 🟡 Orta risk: belirsiz teslim tarihi, muğlak kapsam
   - 🟢 Düşük risk: standart şartlar
4. CEO'ya özet geç:

```
📄 Sözleşme: XYZ İnşaat — Alt Yüklenici

💰 Toplam: 4.200.000 TL + KDV
📅 Teslim: 180 gün (15 Kasım 2026)
⚠ Riskler:
  • Gecikme cezası günlük %0.5 (yüksek — %0.1-0.2 öner)
  • Fesih maddesi tek taraflı (karşılıklı olmalı)
✅ Garanti süresi 2 yıl (standart)
```

### 3. Evrak Arşivleme

1. Analiz edilen evrakı vault'a kaydet:
   - `vault/template/evrak/<yil>/<ay>/`
2. Metadata çıkar (tarih, tür, taraflar, tutar)
3. Arama indeksine ekle (ileride "XYZ ile sözleşme neydi?" sorusuna hazırlık)

## Kullanılacak Araçlar

```bash
# PDF → text
python3 -c "import pymupdf; doc=pymupdf.open('dosya.pdf'); print(''.join([p.get_text() for p in doc]))"

# E-fatura XML parse
python3 -c "import xml.etree.ElementTree as ET; ..."
```

## Pitfalls

- Taranmış PDF'ler → OCR gerekir (pymupdf + tesseract)
- El yazısı sözleşmeler → OCR başarısı düşük
- Türkçe hukuk terminolojisi → KV Router ile anlamlandırma
- GİB e-fatura format değişiklikleri → periyodik kontrol gerek
