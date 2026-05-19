---
name: ceo-ik-rituelleri
description: "İK Ritüelleri — SGK/vergi deadline takibi, bordro hatırlatma, onboarding/offboarding checklists."
version: 1.0.0
author: CEO Asistanı
platforms: [linux]
metadata:
  target: turkish-sme-ceo
  tools: [terminal, file, web_search]
---

# İK Ritüelleri

Türk KOBİ'lerinde İK genelde CEO'nun üstündedir. SGK, vergi, bordro
tarihleri kaçar. Bu skill kaçırmaz.

## Tetikleyiciler

- Ay başı / ay sonu (otomatik cron)
- CEO "personel durumu", "SGK", "maaş", "izin" dediğinde
- Yeni işe alım / çıkış olduğunda

## Workflow

### 1. Ay Başı Kontrol Listesi (her ayın 1'i)

1. Bu ayın kritik tarihlerini çıkar:
   - SGK bildirimi son günü (ayın 23'ü)
   - Muhtasar beyanname son günü (ayın 26'sı)
   - KDV beyannamesi son günü (ayın 28'i)
   - Maaş ödeme günü (şirket politikası)
2. CEO'ya WhatsApp:

```
📅 Mayıs 2026 — Kritik Tarihler

23 Mayıs — SGK bildirimi son gün ⚠
26 Mayıs — Muhtasar beyanname
28 Mayıs — KDV beyannamesi
30 Mayıs — Maaş ödemesi (45 çalışan)
```

### 2. Deadline Yaklaşım Uyarısı

Her deadline'dan 3 gün, 1 gün, ve son gün önce hatırlat:

```
⚠ SGK bildirimi için 3 gün kaldı (son: 23 Mayıs)
```

### 3. Personel Durum Özeti

CEO "personel durumu" dediğinde:

```
👥 Personel Özeti — Mayıs 2026

Toplam: 45 çalışan
• Ofis: 12
• Saha: 28
• Yönetim: 5

📋 Bu ay: 2 işe giriş, 0 çıkış
🏖 İzin: 3 kişi
🤒 Rapor: 1 kişi (5 gündür)
⚠ Deneme süresi biten: 2 kişi (karar bekliyor)
```

### 4. Onboarding Checklist

Yeni çalışan başladığında:
1. SGK işe giriş bildirgesi (1 gün içinde)
2. İş sözleşmesi imzalat
3. E-posta / sistem hesapları aç
4. Ekipman tahsisi (bilgisayar, telefon, araç)
5. Oryantasyon programı (ilk hafta)
6. Deneme süresi takibi (2 ay sonra uyar)

## Vault Yapısı

```
vault/template/insanlar/
├── personel-listesi.md
├── izin-takip.md
├── sgk-takvimi.md
└── onboarding/
    ├── ahmet-yilmaz.md
    └── mehmet-demir.md
```

## Pitfalls

- SGK/takvim değişiklikleri → Resmi Gazete takibi gerek
- Resmi tatiller → her yıl güncelle
- Toplu iş sözleşmesi varsa özel maddeler manuel eklenmeli
