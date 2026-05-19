# Sezonsal Pattern

# Yıllık tekrar eden doluluk / talep deseni.
# Customer onboarding'inde tahmin ile başlar, ilk 12 ay gerçek veriden öğrenir.

baseline_tipi: year-round-low-winter
# year-round-low-winter: Kapadokya, İstanbul boutique
# coastal-may-october: Bodrum, Çeşme, Antalya
# year-round-stable: İstanbul city center

## Aylık doluluk tahmini (yüzde)
ocak: 30
subat: 28
mart: 45
nisan: 65
mayis: 78
haziran: 85
temmuz: 90
agustos: 88
eylul: 80
ekim: 70
kasim: 45
aralik: 50

## Özel günler / dalgalanmalar
## Format: tarih | etki | sebep
# 2026-04-23: +%15 | resmi tatil
# 2026-12-31: +%30 | yilbasi
