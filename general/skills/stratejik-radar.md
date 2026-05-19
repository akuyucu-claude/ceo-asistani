---
name: ceo-stratejik-radar
description: "Stratejik Radar — sektör haberleri, rakip izleme, ihale takibi, regülasyon değişiklikleri."
version: 1.0.0
author: CEO Asistanı
platforms: [linux]
metadata:
  target: turkish-sme-ceo
  tools: [terminal, file, web_search, web_extract]
---

# Stratejik Radar

CEO'nun dış dünyaya açılan penceresi. Sektörde ne oluyor, rakip ne
yapıyor, hangi ihale çıktı, hangi regülasyon değişti — hepsini tarar.

## Tetikleyiciler

- Her sabah 06:30 otomatik tarama (cron)
- CEO "sektör", "rakip", "ihale", "haber" dediğinde
- Önemli bir gelişme tespit edildiğinde (anlık alert)

## Workflow

### 1. Sabah Sektör Taraması (06:30)

Kaynakları tara:
- Google News RSS (sektör keyword'leriyle)
- Resmi Gazete (bugünkü sayı)
- EKAP (ihale portalı)
- Rakip web siteleri / LinkedIn
- Sektör bültenleri (email)

Her kaynaktan en fazla 5 önemli madde çıkar.

### 2. Sektör Radarı Özeti

`vault/template/raporlar/sektor-radari.md` güncelle:

```markdown
items:
- FİYAT: Demir-çelik fiyatları %3 arttı: Kardemir yeni liste açıkladı
- IHALE: İstanbul BB: Yol yapım ihalesi, 180M TL yaklaşık maliyet
- RAKIP: YapıMerkez yeni ekipman yatırımı
- REGULASYON: Yapı denetim yönetmeliğinde değişiklik (Resmi Gazete)
- EKONOMI: TCMB faiz kararı bu hafta Perşembe
```

### 3. İhale Takibi

1. EKAP'tan şirketin faaliyet alanına uygun ihaleleri tara
2. Her ihale için:
   - İhale makamı
   - Yaklaşık maliyet
   - Son başvuru tarihi
   - Kalan gün
   - Hazırlık durumu (vault'tan)
3. Yaklaşan deadline'ları CEO'ya bildir

### 4. Rakip İzleme

Takip edilen rakipler için:
- Yeni proje / ihale kazanımları
- Ekipman / filo yatırımları
- İşe alım ilanları (büyüme işareti)
- Finansal haberler (varsa)
- Sosyal medya / LinkedIn aktiviteleri

Haftalık rakip özeti (Pazartesi sabahı).

### 5. Regülasyon Takibi

Resmi Gazete'den sektörü ilgilendiren değişiklikleri tara:
- Çevre mevzuatı
- İş sağlığı ve güvenliği
- İmar / yapı denetim
- Vergi düzenlemeleri
- İhale mevzuatı

## Kaynaklar

| Kaynak | URL | Sıklık |
|--------|-----|--------|
| Google News | `site:ekap.kik.gov.tr` | Günlük |
| EKAP | `ekap.kik.gov.tr` | Günlük |
| Resmi Gazete | `resmigazete.gov.tr` | Günlük |
| Rakip siteleri | manuel liste | Haftalık |

## Pitfalls

- EKAP captcha koyabilir → browser tool gerekebilir
- Resmi Gazete formatı değişebilir
- Rakip bilgileri eksik/yanlış olabilir → "teyit edilmemiş" etiketi koy
- SEO/spam haberleri filtrele → güvenilir kaynak whitelist'i kullan
