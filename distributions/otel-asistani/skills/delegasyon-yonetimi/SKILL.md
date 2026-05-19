---
name: ceo-delegasyon-yonetimi
description: "Delegasyon Yönetimi — görev delege etme, otomatik takip, hatırlatma, eskalasyon."
version: 1.0.0
author: CEO Asistanı
platforms: [linux]
metadata:
  target: turkish-sme-ceo
  tools: [terminal, file, whatsapp]
---

# Delegasyon Yönetimi

CEO'nun en kritik yeteneği: doğru işi doğru kişiye delege etmek ve
takibini unutmamak. Bu skill delege edilen her görevi takip eder,
hatırlatır, ve gerektiğinde eskalasyon yapar.

## Tetikleyiciler

- CEO "X'i Y'ye delege et" dediğinde
- Her saat başı gecikmiş delegasyon kontrolü (cron)
- Delegasyon deadline'ı yaklaştığında (otomatik)

## Workflow

### 1. Yeni Delegasyon

CEO "Ahmet'e ABC Demir sipariş takibini yarına kadar delege et" dediğinde:

1. Delegasyonu vault'a kaydet:
   ```markdown
   ## d-20260518-001
   - gorev: ABC Demir sipariş takibi
   - delege: Ahmet Bey
   - deadline: 2026-05-19 18:00
   - durum: devam-ediyor
   - olusturma: 2026-05-18 09:00
   ```
2. Delege edilen kişiye WhatsApp/email:
   ```
   📋 Yeni görev: ABC Demir sipariş takibi
   ⏰ Son teslim: 19 Mayıs 18:00
   ```
3. CEO'ya onay: "✓ ABC Demir → Ahmet Bey'e delege edildi (yarın 18:00)"

### 2. Otomatik Takip

Her saat başı:
1. Tüm aktif delegasyonları tara
2. Deadline'ı geçenleri "gecikmiş" olarak işaretle
3. Yaklaşanları (son 3 saat) "yaklasiyor" olarak işaretle

### 3. Hatırlatma Sistemi

| Zaman | Aksiyon |
|-------|---------|
| Deadline'dan 1 gün önce | Delegeye: "Yarın son gün" |
| Deadline'dan 3 saat önce | Delegeye: "3 saat kaldı" |
| Deadline geçti | Delegeye: "Geciktin — ne zaman?" |
| 1 gün gecikme | CEO'ya: "Ahmet ABC Demir'i tamamlamadı" ⚡ ESKALASYON |

### 4. Tamamlama

CEO "ABC Demir takibi tamam" dediğinde:
1. Delegasyon durumunu "tamamlandi" yap
2. Delegeye: "✓ ABC Demir görevi tamamlandı, teşekkürler"
3. Vault'u güncelle
4. Dashboard'u yenile

## Vault Veri Formatı

### delegasyon/aktif.md
```markdown
## d-20260518-001
- gorev: ABC Demir sipariş takibi
- delege: Ahmet Bey
- deadline: 2026-05-19 18:00
- durum: devam-ediyor
- eskalasyon: false
```

DURUM değerleri:
- `devam-ediyor` — süresi içinde
- `yaklasiyor` — son 3 saat
- `gecikmis` — deadline geçti
- `eskalasyon` — CEO'ya bildirildi
- `tamamlandi` — bitti

### delegasyon/arsiv.md
Tamamlanan delegasyonlar buraya taşınır (istatistik için).

## Dashboard Entegrasyonu

```bash
python3 update_dashboard.py --vault /opt/<customer>/vault ...
```

Dashboard'da gösterilecek:
- Kişi başına delegasyon sayısı ve durumu
- Gecikmiş delegasyon alert'leri
- Eskalasyon bekleyenler

## Pitfalls

- Delege WhatsApp'ta yoksa email/sms alternatifi gerek
- Çok fazla delegasyon varsa spam gibi algılanabilir → günde max 3 hatırlatma/kişi
- CEO "tamam" derse ama delege etmediği bir şey için → hatalı eşleşme olabilir
- Hafta sonu deadline → otomatik iş gününe kaydır
