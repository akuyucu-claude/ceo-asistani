---
name: ceo-tedarik-zinciri
description: "Tedarik Zinciri Radarı — sipariş takibi, tedarikçi iletişimi, gecikme alert'leri."
version: 1.0.0
author: CEO Asistanı
platforms: [linux]
metadata:
  target: turkish-sme-ceo
  tools: [terminal, file, web_search]
---

# Tedarik Zinciri Radarı

İnşaat, üretim, toptan satış — tedarik zinciri kırılırsa iş durur.
Bu skill kırılmadan haber verir.

## Tetikleyiciler

- CEO "tedarik durumu", "siparişler", "hammadde" dediğinde
- Her gün 08:00 otomatik kontrol
- Tedarikçiden gecikme bildirimi geldiğinde (email/WhatsApp)

## Workflow

### 1. Aktif Sipariş Takibi

1. `vault/template/tedarik/siparisler.md` dosyasından aktif siparişleri oku
2. Her siparişin durumunu kontrol et:
   - Sipariş tarihi
   - Beklenen teslim tarihi
   - Kalan gün / gecikme günü
   - Tedarikçi son iletişim tarihi
3. Gecikmiş veya yaklaşanları işaretle

### 2. Günlük Tedarik Özeti (08:00)

CEO'ya WhatsApp:

```
🏭 Tedarik Durumu — 18 Mayıs

Aktif sipariş: 12
✅ Zamanında: 8
⚠ Yaklaşan (3 gün içinde): 2
🔴 Gecikmiş: 2

🔴 ABC Demir — 45 ton demir, 2 gün gecikti
   Son iletişim: 15 Mayıs
   ⚡ Aksiyon: Tedarikçiyi ara, alternatif ara

⚠ Çimento A.Ş. — 100 ton, yarın teslim
   Son teyit: 17 Mayıs (OK)
```

### 3. Tedarikçi Performans Takibi

Her tedarikçi için kart:
- Son 6 ay teslimat performansı (%)
- Ortalama gecikme günü
- Fiyat değişim trendi
- Alternatif tedarikçi var mı?

CEO "X tedarikçisi nasıl?" dediğinde anında özet.

### 4. Kritik Malzeme Uyarısı

Stok kritik seviyenin altına düşerse:
```
⚠ Kritik stok: İnşaat demiri (12 ton kaldı — 5 günlük)
📋 Son sipariş: 45 ton, 2 gün gecikti
🔄 Alternatif: Çelik Yapı A.Ş. (3 günde teslim, +%8 fiyat)
```

## Vault Veri Formatı

### siparisler.md
```markdown
## Aktif Siparişler
- SIPARIS_NO | TEDARIKCI | MALZEME | MIKTAR | SIPARIS_TARIH | TESLIM_TARIH | DURUM
- DURUM: "zamaninda", "yaklasiyor", "gecikmis"
```

### tedarikciler.md
```markdown
## ABC Demir
- iletisim: Ahmet Bey — 0532 XXX XXXX
- performans: %85 zamanında teslim
- alternatif: Çelik Yapı A.Ş.
```

## Pitfalls

- Tedarikçi manuel güncellemezse veri güncel olmaz
- WhatsApp'tan sözlü teyitler vault'a işlenmeli
- Döviz bazlı siparişlerde kur dalgalanması riski var → ayrıca takip et
