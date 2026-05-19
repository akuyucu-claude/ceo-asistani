---
name: ceo-gundem-yonetimi
description: "CEO Gündem Yönetimi — toplantı hazırlık, aksiyon takibi, follow-up otomasyonu."
version: 1.0.0
author: CEO Asistanı
platforms: [linux]
metadata:
  target: turkish-sme-ceo
  tools: [google-calendar, whatsapp, terminal, file, web_search]
---

# CEO Gündem Yönetimi

Sabah rutini: CEO'nun gününü hazırlar. Toplantı öncesi briefing, aksiyon
takibi, ve akşam gün sonu özeti üretir.

## Tetikleyiciler

- CEO "günaydın", "bugün ne var", "gündem" dediğinde
- Her sabah 07:00'de otomatik (cron)
- Her akşam 19:00'da gün sonu özeti (cron)

## Workflow

### 1. Sabah Briefing (07:00)

1. Google Calendar'dan bugünün toplantılarını çek
2. Her toplantı için hazırlık durumunu kontrol et:
   - Katılımcı listesi var mı?
   - Gündem maddeleri net mi?
   - Gerekli evraklar hazır mı? (vault'ta ara)
   - Önceki toplantıdan kalan aksiyonlar tamamlandı mı?
3. `vault/template/gundem/bugun.md` dosyasını güncelle
4. Dashboard'u yenile: `python3 update_dashboard.py ...`
5. CEO'ya WhatsApp'tan gönder:

```
☀️ Günaydın. Bugün 3 toplantın var.

09:30 İcra Kurulu — ✓ Hazır
11:00 XYZ İnşaat Tahsilat — ✓ Hazır  
14:30 İBB İhale Teknik — ⚡ Eksik (metraj dosyası)

⚠ 3 aksiyon gecikmiş durumda.
```

### 2. Toplantı Öncesi (toplantıdan 15 dk önce)

1. Toplantı dosyasını vault'tan oku
2. CEO'ya WhatsApp'tan hatırlat:

```
📋 15 dk sonra: İcra Kurulu Toplantısı
👥 CFO, COO, Teknik Müdür
📄 Hazırlık dosyası: vault/projeler/icra-kurulu.md
⚠ Geçen toplantıdan açık: Bütçe revizyonu kararı
```

### 3. Gün Sonu Özeti (19:00)

1. Bugün tamamlanan aksiyonları kontrol et
2. Yarının takvimini çek
3. CEO'ya WhatsApp'tan özet:

```
🌙 Gün sonu — 18 Mayıs

✅ Tamamlanan: 3 aksiyon
⏳ Yarına kalan: 2 aksiyon
📅 Yarın: 4 toplantı (ilk 08:30)

⚠ Yarın SGK bildirimi son gün!
```

### 4. Aksiyon Takip

Her aksiyon için:
1. `vault/template/gundem/aksiyonlar.md` dosyasından durumu oku
2. Gecikmiş aksiyonları tespit et
3. CEO'ya günde bir kez (sabah briefing'te) hatırlat
4. Aksiyon tamamlandığında vault'u güncelle

## Vault Veri Formatı

### bugun.md
```markdown
tarih: 2026-05-18
toplanti_sayisi: 3
erken_toplanti: 09:30

## Toplantılar
- SAAT | BAŞLIK | KATILIMCILAR | KONU | DURUM
- DURUM: "hazir" veya "eksik"
```

### aksiyonlar.md
```markdown
gecikmis_sayisi: 3
bugun_sayisi: 5
bu_hafta_sayisi: 11

## Gecikmiş
- AKSIYON AÇIKLAMASI
```

## Takvim Entegrasyonu

Google Calendar API üzerinden. Hermes, Composio MCP ile Google Calendar'a bağlanır.

```python
# Composio tool call: google-calendar-list-events
# Format: bugün 00:00 - 23:59 arası event'leri çek
```

## Pitfalls

- Toplantı iptal edilirse vault manuel güncellenmeli (henüz otomatik değil)
- Türkçe tatil günleri (resmi tatiller) takvimden okunamazsa manuel eklenmeli
- CEO WhatsApp'tan "toplantı iptal" derse aksiyon al

## Dashboard Entegrasyonu

Her güncellemeden sonra:
```bash
python3 /opt/ceo-asistani/update_dashboard.py \
  --vault /opt/<customer>/vault \
  --output /var/www/<customer>/index.html
```
