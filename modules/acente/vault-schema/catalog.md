# Tur Katalog (UC-D1 Birincil Kaynak)

# Bu dosya inquiry-to-itinerary skill'i tarafından okunur.
# Onboarding'de operatör Google Sheet template'inden veya PDF'ten upload eder.
# Sonra bu markdown'a normalize edilir.

son_guncelleme: REPLACE_ME

## Tur Ürünleri

# Her ürün için minimum alanlar:
# - id: kısa unik kod
# - ad: pazarlama adı
# - sure: kaç gün
# - kategori: cultural | coastal | adventure | religious | mice
# - varislar: hangi şehirler
# - dahil: ne dahil (uçak, otel, transfer, rehber, müze, kahvaltı, ...)
# - haric: ne dahil değil
# - guruplar: min/max kişi
# - sezon: ay aralığı
# - taban_fiyat_eur: kişi başı, çift kişilik standart oda
# - dil_destegi: hangi dilde rehber mümkün

# --- Örnek (gerçek katalogla değiştirilecek) ---
# id: KAPA-3D
# ad: Kapadokya 3 Gün Kültür Turu
# sure: 3 gün / 2 gece
# kategori: cultural
# varislar: [Kapadokya]
# dahil: [transfer, otel, kahvaltı, rehber, müze giriş]
# haric: [öğle/akşam yemeği, balon turu]
# guruplar: 2-15
# sezon: [4, 5, 6, 7, 8, 9, 10, 11]
# taban_fiyat_eur: 450
# dil_destegi: [EN, DE, ES, FR, IT, RU, JA, KO, ZH]
