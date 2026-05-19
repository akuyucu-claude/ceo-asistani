# PRD — Otel Asistanı

**Product codename:** `otel-asistani`
**Tagline:** *AI Önbüro Asistanı for independent boutique hotels in Türkiye*
**Status:** Draft v1 · **Owner:** Product · **Last updated:** 2026-05-19

---

## 1. Summary

Otel Asistanı is a managed AI agent that performs the front-office / reservations work for independent boutique hotels (30–100 rooms) in Türkiye. It runs on the shared Hermes-based platform (see `ARCHITECTURE.md`) with the `modules/hotel/` vertical pack enabled.

It does five things, very specifically:

1. Sends the owner a daily morning briefing on WhatsApp at 07:00
2. Monitors OTA channel rate parity hourly and alerts on anomalies
3. Replies to guest WhatsApp inquiries in TR / EN / RU / DE in under 5 minutes
4. Drafts responses to Google / TripAdvisor / Booking reviews and produces a weekly Friction Map
5. Projects 13-week cash flow against the property's seasonal pattern and warns of cash crunches 4 weeks in advance

It does **not** do dynamic pricing (that's IDeaS / Duetto), channel management (that's HotelRunner), booking engine (that's HotelRunner / Booking Property Tools), or PMS (that's Elektraweb / Protel). We sit alongside those systems, not in their place.

---

## 2. Problem & opportunity

Boutique hotels in Türkiye are caught between two structural pressures:

- **OTA dependence is shrinking margin.** Booking.com and Expedia take 15–25% commission (on gross including VAT and accommodation tax). For a 40-room property in Kapadokya doing ~₺40M/yr revenue, that's ₺6–10M/yr leaving the bottom line. Owners know this but can't out-execute Booking's marketing.
- **Front office is the operational bottleneck.** Multilingual guest inquiries (Kapadokya alone hosts guests from 170 nationalities), review responses, OTA parity checks, daily revenue tracking, supplier coordination — all done by an owner-operator or a single GM. A new front-office hire costs ₺40,000–80,000/month fully loaded but works 8 hours, in one language, with weekends off.

There is no AI product in the Turkish boutique hotel market today that ships an **agentic, multilingual, front-office-assistant** workflow. The closest incumbent is HotelRunner (Istanbul HQ, 64K+ accommodations globally) which is moving on the AI side via Autopilot pricing and AI Review Center — but as features bolted onto a channel manager, not as a job-title replacement.

**Window:** 6–12 months before HotelRunner or a similar incumbent ships an equivalent product. After that, we are competing on incumbency.

---

## 3. ICP — Ideal Customer Profile

### Primary target

| Attribute | Value |
|---|---|
| Property size | 30–100 rooms |
| Property type | Independent boutique (Bakanlık Belgeli or Özel Belgeli) |
| Decision maker | Owner (70%) or GM (30%); owner-operator preferred |
| Region | **Tier 1: Kapadokya** (Göreme, Ürgüp, Uçhisar, Mustafapaşa) |
| Existing stack | HotelRunner or Elektraweb + Booking + WhatsApp + Excel |
| Multilingual guest mix | At least 4 source languages (TR + EN + 2 more) |
| Annual occupancy | ≥ 55% (year-round; signals professional operation) |
| Owner profile | 2nd-generation hotelier or returning-expat professional; English literate |
| Technology readiness | WhatsApp daily, cloud apps comfortable, Excel-fluent |

### Tier-2 expansion (after first 20 paying customers)

- **İstanbul boutique** — Sultanahmet, Karaköy, Galata, Beyoğlu. Year-round operation, diverse multilingual mix.
- **Bodrum peninsula** — Yalıkavak, Türkbükü, Bitez, Torba. UK / DE / domestic mix; seasonal but high-value.

### Explicitly excluded from V1

- International chains (Hilton, Marriott, Accor/Rixos, IHG, Wyndham) — Opera Cloud mandate and brand standards approval make property-level sales impossible.
- Large Turkish chains (Maxx Royal, Titanic, Limak, Divan, Voyage) — enterprise RFP cycles, 8–10 named accounts max, not a GTM target.
- All-inclusive resort properties (Antalya / Belek) — tour-operator-driven, low direct-booking, F&B-heavy ops; different product.
- Pansiyon / apart hotels < 15 rooms — wrong ACV bracket.
- Çeşme / Alaçatı — aesthetically appealing but domestic-Turkish-dominant; multilingual value prop weak.

### Realistic top-of-funnel (TAM/SAM/SOM)

- TAM: ~3,000 independent Turkish hotels 30+ rooms
- SAM: ~550–800 properties in the 4 boutique-dense clusters (Bodrum + Çeşme/Alaçatı + Kapadokya + İstanbul boutique)
- SOM (12 months): ~200–250 Kapadokya boutiques; realistic land target 50–80 paying

---

## 4. Buyer & user

**Buyer (signs the contract, pays the bill):** Owner or GM.

**Primary user (interacts daily):** Owner via WhatsApp (morning briefing, ad-hoc questions). Secondary user: front office staff (reviews drafts, edits guest messages, monitors dashboard).

**Champion vs. blocker map:**

| Persona | Stance | How we win |
|---|---|---|
| Owner | Champion (buyer, primary user) | Daily briefing creates immediate "asistan gibi" feeling |
| GM | Mostly champion (workload reducer) | Frame as "your AI asistan" not "your replacement" |
| Front-office staff | Mixed — fear of replacement | Position as drafting tool that they review and edit; never auto-send |
| Bookkeeper / accountant | Neutral | Light touch in V1; will care if PMS integration arrives |

---

## 5. Positioning

**Headline:** *Bir önbüro personelinin yaptığı işi, yorulmadan, 4 dilde, 7/24 yapar. Ayda ₺50K.*

**Anchor comparison (not the software market — the staffing market):**

| | Önbüro personeli (yeni alım) | Otel Asistanı |
|---|---|---|
| Aylık maliyet (yüklü) | ₺40,000–80,000 | ₺50,000 |
| Çalışma süresi | 8 saat / gün, 6 gün / hafta | 24 saat / gün, 7 gün / hafta |
| Diller | 1–2 | TR + EN + RU + DE (V1) |
| İzin / hastalık | Var | Yok |
| Tutarlılık | Değişken | Değişmez |
| Bilgi devri | Çıkışta kaybolur | Vault'ta birikir |

**Pozisyonlama testi (cümle uzunluğu):**
"Otel Asistanı, mal sahibine her sabah dünkü doluluğu ve gelir özetini WhatsApp'tan yollar, OTA fiyat sapmalarını saatlik izler, konuk mesajlarına 4 dilde 5 dakika içinde cevap verir."

Bu cümle satılır. Daha uzun bir cümleye ihtiyacımız varsa pozisyonlama kırıktır.

**Buying triggers (positive, value-first):**

1. *"Booking %20 komisyon kesiyor, direkt rezervasyona dönmek istiyorum"* — UC-H2 hooks here
2. *"Konuklar gece WhatsApp yazıyor, sabaha kadar cevap veremiyoruz"* — UC-H3
3. *"Sabah panoya bakacak vaktim yok, telefondan görmek istiyorum"* — UC-H1
4. *"Yorumlara cevap yazmaya zamanım yetmiyor, Google ranking düşüyor"* — UC-H4
5. *"Kasım–Şubat'ı görmüyorum, nakit ne zaman daralacak bilmiyorum"* — UC-H5

**KVKK / compliance is a comfort, not the headline.** Mentioned on slide 5 of any deck, not slide 1.

---

## 6. Use cases

### UC-H1 — Sabah Patron Brifingi *(MVP)*

**Trigger:** Daily, 07:00 local time (configurable). Also on-demand via WhatsApp "günaydın" or "brifing".

**Inputs (data sources):**
- PMS (Elektraweb / Protel) — yesterday's occupancy, today's arrivals, departures, ADR
- GBP API — new reviews since yesterday
- Booking / Expedia extranet — yesterday's bookings, cancellations
- Vault `modules/hotel/sezon-projeksiyon.md` — current week vs. forecast
- Vault `core/calendar/` — owner's calendar for today

**Output:** A single WhatsApp message to the owner:

```
☀ Günaydın. 19 Mayıs Salı.

🏨 Dün doluluk %78 (28/36 oda) — ADR ₺3.450, RevPAR ₺2.691
📥 Bugün 6 check-in (2'si havaalanı transfer talep etmiş)
📤 Bugün 4 check-out, 3'ü 11:00 öncesi
⭐ 2 yeni yorum — Google'da 9.4 (TR konuk: çok memnun · DE konuk: kahvaltı eleştirisi)
📊 Hafta projeksiyonu: doluluk %82 (geçen yıl bu hafta %71)
⚠ Türbükü Booking ₺2.400 — bizdeki ₺2.700, %11 sapma var (UC-H2'de detay)

Bugün 14:00'te bahçe düzenleyicisi ile randevu (takvimde)
```

**Success metrics:**
- Delivered before 07:15 on 95% of days (SLO)
- Owner WhatsApp reply rate ≥ 30% within first 90 days (engagement signal)
- Critical anomaly detection rate ≥ 90% on synthetic test set (rate sapma, review crisis)

**Why a script + cron isn't enough:** the briefing has to *prioritise* daily — some days the rate sapma is the lede, some days a guest crisis is. That requires LLM judgement against the day's actual data.

---

### UC-H2 — Multi-channel Rate Parity + OTA Komisyon Optimization *(MVP)*

**Trigger:** Hourly (`0 * * * *`) during open hours; on-demand on WhatsApp ("fiyat kontrol").

**Inputs:**
- Booking.com Extranet — current property rate per room type per day for next 30 days
- Expedia Partner Central — same
- Agoda (if connected) — same
- Hotel's direct booking site — same (scraping operator's own site is clean)
- Vault `modules/hotel/rate-monitor.md` — baseline rate strategy

**Action:**
- Compare rates across all channels for next 30 days
- Detect parity violations: any channel selling > 3% below the property's chosen anchor
- Detect rate freshness: channels not updated in > 7 days
- Detect commission impact: estimate ₺ loss per parity violation per remaining inventory

**Output:**
- WhatsApp alert to owner on anomaly: *"⚠ Expedia ₺2.100, Booking ₺2.400 — Türbükü Suite 14–17 Mayıs. Tahmini kayıp ₺18.000."*
- Dashboard widget: rate-parity heatmap (rooms × channels × next 14 days)
- Vault entry with full diff

**Success metrics:**
- Median time-to-detection of a parity violation: < 1 hour
- False positive rate < 5% (don't cry wolf — owners stop trusting it)
- ADR uplift attributable in 90-day rolling window: target ≥ 3% (measured via PMS data, A/B impossible — so we report trend)

**Out of scope V1:** auto-correcting the rate. The agent suggests; the human acts. This is a deliberate trust-building choice. V2 may add one-click correct.

---

### UC-H3 — 4-dilde Konuk WhatsApp İletişim *(MVP)*

**Trigger:**
- Incoming WhatsApp message to the hotel's Business number
- Scheduled pre-arrival (24 hours before check-in)
- Scheduled post-stay (24 hours after check-out)

**Inputs:**
- WhatsApp Business API webhook
- PMS reservation lookup (by phone number → reservation)
- Vault `modules/hotel/otel-faq.md` (check-in saatleri, address, parking, kahvaltı, transfer, spa, wifi)
- Vault `modules/hotel/konuklar/<reservation-id>.md` (if existing guest)

**Action:**
- Detect language from message
- Identify guest (matched reservation? returning?)
- Draft reply in guest's language using FAQ + reservation context
- Route critical / unhappy / out-of-policy messages to human (GM) immediately
- For routine FAQ ("what time is check-in?") → high-confidence auto-send (configurable per customer)
- For pre-arrival: send confirmation, transfer offer, check-in instructions in guest language

**Output:**
- Draft message in guest language, in hotel's brand voice
- WhatsApp reply (auto-sent if confidence > threshold AND customer enables auto-send; otherwise queued for staff review)
- Vault entry `modules/hotel/konuklar/<reservation-id>.md` updated with interaction log

**Success metrics:**
- 80% of inbound messages get a high-quality draft within 5 minutes
- 0 incorrect factual claims (no auto-send on anything not in FAQ or PMS)
- Guest satisfaction proxy: NPS-like 1-question post-stay survey response rate
- Off-hours coverage: ≥ 95% of inbound messages 22:00–08:00 get drafted

**Languages V1:** Turkish, English, Russian, German. Tier-2 expansion adds Spanish, Italian, Japanese, Korean, Chinese for Kapadokya / İstanbul.

**Critical rule:** **No auto-send for any message that involves a price, a refund, a cancellation, a complaint, or a special request.** Those always queue for human.

---

### UC-H4 — Yorum Yanıtlama + Friction Map *(V1)*

**Trigger:**
- New review on Google Business Profile (via GBP API webhook or polling)
- New review on Booking / TripAdvisor (via extranet polling)
- Weekly Friction Map digest (Pazar 19:00)

**Inputs:**
- GBP API — operator's own reviews (clean data, official API)
- Booking extranet — operator's own property reviews
- TripAdvisor — *only via official means if available;* not via scraping (see `dropped` section in `ARCHITECTURE.md` philosophy)
- Vault `modules/hotel/otel-faq.md` — hotel's voice / common responses
- Vault `modules/hotel/yorumlar/` — historical review archive

**Action:**
- Aspect-based sentiment: extract which aspect of the stay drove the review (room, kahvaltı, personel, lokasyon, gürültü, vb.)
- Detect language; draft response in review language
- Match hotel's brand voice from historical responses
- Flag operational issues that recur (e.g., "kahvaltı çayı soğuk" appearing in 8 reviews this quarter)
- Weekly Friction Map: top 5 recurring complaints, top 5 recurring praise points, trend direction

**Output:**
- Review response draft (queued for owner / GM approval — never auto-published)
- Weekly Friction Map dashboard widget + WhatsApp digest
- Vault entry per review with sentiment tags

**Success metrics:**
- 100% of reviews get a draft within 24 hours
- 90% of drafts accepted by owner with ≤ 1 edit
- Friction Map identifies an actionable operational issue at least 1×/month

---

### UC-H5 — Sezon-Aware Cash Flow Projection *(V2)*

**Trigger:** Weekly (Saturday 18:00); on-demand via WhatsApp ("nakit projeksiyon").

**Inputs:**
- PMS — confirmed reservations + payment status for next 13 weeks
- Vault `general/finans/tahsilat.md` — open invoices, supplier balances
- Vault `general/finans/fixed-costs.md` — payroll, rent, SGK, utilities baseline
- Historical PMS data — same-week-last-year, same-month-last-year occupancy + ADR
- KV Router seasonal pattern from vault `modules/hotel/sezon-pattern.md`

**Action:**
- Project weekly inflow (confirmed bookings + expected new bookings based on pattern)
- Project weekly outflow (fixed + variable)
- Identify weeks where projected balance < safety threshold (configurable, default 2 months payroll)
- Suggest interventions (early discount sale, deposit-pull push, supplier renegotiation)

**Output:**
- 13-week cash chart on dashboard
- WhatsApp alert if any week in the next 8 falls below safety threshold
- Vault entry `modules/hotel/sezon-projeksiyon.md`

**Success metrics:**
- Cash crunch identified ≥ 4 weeks before it would actually hit
- Projection accuracy: within ±10% of actual at 4-week horizon

**V2 because:** requires reliable PMS integration. MVP and V1 ship without this.

---

## 7. Out of scope (explicitly NOT V1)

| Feature | Why excluded | Owner |
|---|---|---|
| Dynamic pricing / RMS | IDeaS / Duetto / Atomize own this; we're not in revenue management | Industry |
| Channel manager | HotelRunner's territory; we partner / read-only against it | HotelRunner |
| Booking engine | HotelRunner, Booking Property Tools, NetAffinity own this | HotelRunner |
| F&B POS / restaurant ops | Sambapos, Adisyo, Elektra-F&B own this | Sambapos / Adisyo |
| Loyalty program | Not a meaningful pain for 30–100 room boutique | – |
| Guest-facing mobile app | Chain territory; not a boutique need | Chain brands |
| Hardware (locks, kiosks) | Not our business | Hardware vendors |
| Multi-property management | V3 — only if a customer asks (rare for our ICP) | – |
| Direct booking engine | Out — see above | – |
| OTA auto-correction | Trust-building requires human-in-loop V1 | – |

---

## 8. Success metrics

### Customer-level (every customer dashboard reports these to us)

| Metric | Target | How measured |
|---|---|---|
| Daily briefing delivery SLO | ≥ 95% on-time | Internal log |
| Median guest reply draft latency | ≤ 5 min | Vault event log |
| Rate parity detection latency | ≤ 60 min from violation | Synthetic + real signal |
| Review draft acceptance rate | ≥ 90% accepted with ≤ 1 edit | Dashboard click-through |
| Owner WhatsApp engagement | ≥ 1 interaction / day average | Gateway log |

### Business-level (us)

| Metric | Target Month 6 | Target Month 12 |
|---|---|---|
| Paying customers | 10 | 50 |
| Logo retention (12-mo) | – | ≥ 85% |
| Net ACV | ₺50K | ₺55K (modest creep allowed) |
| Pipeline velocity | 20–30 week median cycle | Same (category creation) |
| Referenceable customers | 3 case studies | 10 case studies |
| Kapadokya market penetration | 5% of boutique cluster | 15% |

---

## 9. Pricing model

**V1 (months 0–12): single SKU, no module pricing.**

| Tier | Aylık | Yıllık | Kapsam |
|---|---|---|---|
| Design Partner (first 5) | ₺25,000 | ₺300,000 | Tüm UC, case study + testimonial karşılığında |
| Launch | ₺50,000 | ₺600,000 | Tüm UC, standart SLA |
| Çoklu mülk (sahibi 2+ otel) | ₺40,000/mülk | – | Aynı sahip indirim |

**No** per-message, per-API-call, or usage-based pricing in V1. Flat, predictable, easy to sell. Inference cost containment is our problem, not the customer's.

**Contract structure:** 12-month minimum, monthly billing in TL, annual prepay 10% discount. Quarterly value review.

**Setup fee:** ₺15,000 one-time (covers onboarding labour). Waived for design partners.

**Why ₺50K positioning:** anchor against a new front-office hire (₺40–80K loaded), not against PMS software (₺3–15K). Every sales conversation that ends up benchmarked against HotelRunner's pricing is a lost deal — disqualify those.

---

## 10. Architecture mapping

This product runs on the shared platform (`docs/ARCHITECTURE.md`). The specifics:

```
modules/hotel/
├── skills/
│   ├── sabah-patron-brifingi.md         ← UC-H1
│   ├── rate-parity-monitor.md           ← UC-H2
│   ├── konuk-iletisim.md                ← UC-H3
│   ├── yorum-yanit-ve-friction-map.md   ← UC-H4
│   └── sezon-cash-flow.md               ← UC-H5
├── connectors/
│   └── manifest.yaml
│       required:
│         - whatsapp-business
│         - gbp
│         - booking-extranet
│       optional:
│         - expedia-extranet
│         - hotelrunner
│         - elektraweb-pms
│         - protel-pms
├── vault-schema/
│   ├── otel.md                          # company profile
│   ├── otel-faq.md                      # check-in, parking, kahvaltı, ...
│   ├── doluluk.md
│   ├── konuklar/.gitkeep
│   ├── yorumlar/.gitkeep
│   ├── rate-monitor.md
│   ├── sezon-projeksiyon.md
│   └── sezon-pattern.md
└── widgets/
    ├── occupancy.html.partial
    ├── ota-revenue.html.partial
    ├── rate-parity.html.partial
    ├── review-sentiment.html.partial
    └── cash-projection.html.partial
```

**Customer profile example:**

```toml
[customer]
slug = "kapadokya-cave-otel"
display_name = "Kapadokya Cave Otel"
domain = "dashboard.kapadokyacaveotel.com.tr"
beachhead = "kapadokya"

[modules]
core    = true
general = true
hotel   = true

[modules.hotel]
languages = ["tr", "en", "ru", "de"]
auto_send_threshold = "faq-only"        # faq-only | confident | never
brand_voice = "warm-formal-tr"
seasonal_pattern_baseline = "year-round-low-winter"

[connectors]
whatsapp_business     = "credentials/whatsapp.json"
google_business       = "credentials/gbp.json"
booking_extranet      = "credentials/booking.json"
elektraweb_pms        = "credentials/elektraweb.json"
```

---

## 11. Data sources & integrations

| Source | Method | Status V1 | Notes |
|---|---|---|---|
| WhatsApp Business API | Official Meta API via gateway | **Required MVP** | 2–4 week approval; start during onboarding |
| Google Business Profile | Official GBP API, OAuth | **Required V1** | 14-day approval — submit Week 1 |
| Booking.com Extranet | Operator-granted access | **Required MVP** | Read-only credentials in vault |
| Expedia Partner Central | Operator-granted | V1 | Same pattern as Booking |
| HotelRunner | API (if customer subscribes) | V1 | Read-only; we don't disrupt their channel manager |
| Elektraweb PMS | CSV daily export (MVP), API later | MVP via CSV | API integration deferred to V2 |
| Protel / Opera PMS | CSV daily export (MVP), API later | V1 via CSV | Same |
| TripAdvisor | None (B2B API forbidden) | – | Manual upload only if customer requests |
| Otelz / TatilSepeti / TatilBudur | Operator-granted, if used | V2 | Deferred |
| Bank account API | Composio MCP (where available) | V3 | Long approval cycle in Türkiye |

**MVP data minimum to ship a customer:** WhatsApp Business + GBP + Booking Extranet + PMS daily CSV. Everything else is V1 or later.

---

## 12. Onboarding flow

Target: customer goes from contract-signed to live dashboard in **5 business days**.

| Day | Operator does | We do |
|---|---|---|
| Day 0 | Sign contract + KVKK DPA | Provision VM, create vault, generate profile.toml |
| Day 1 | Grant Gmail OAuth, share company profile (.md template), share otel-faq.md content | Spin up Hermes, install core/general/hotel modules, install connectors |
| Day 2 | Grant GBP manager access (14-day clock starts now), share Booking extranet credentials | Configure GBP API request, connect Booking, ingest first review batch |
| Day 3 | Provide WhatsApp Business number + Meta verification docs | Submit WhatsApp Business API application; configure WhatsApp gateway |
| Day 4 | Daily PMS CSV export to designated S3-compatible bucket | Build PMS adapter; first occupancy ingestion |
| Day 5 | Review test outputs (briefing dry-run, sample guest reply, sample review draft) | Tune brand voice, FAQ, auto-send thresholds |
| Day 6+ | Go-live + 1-week observation period | Monitor, adjust, send daily customer success ping |

**Stuck-points to manage:**
- WhatsApp Business API approval can take 2–4 weeks. We pre-stage with a sandbox number for testing during onboarding; switch to production number when Meta approves.
- GBP API access is 14 days. We submit on Day 2.
- Some customers don't have WhatsApp Business — we walk them through the migration from personal WhatsApp.

---

## 13. KVKK & data governance

Inherits the platform stance (`docs/ARCHITECTURE.md` §12). Hotel-specific additions:

- **Konuk verisi:** name, contact, passport / TC kimlik (for KVKK Decision 2025/2120 — registry), preferences, stay history. All stored in `vault/modules/hotel/konuklar/<reservation-id>.md` per customer VM.
- **PII redaction at KV Router** is required for any skill that touches passport / TC kimlik.
- **Konuk silme talebi:** documented runbook — `rm` of specific vault file + audit log entry. Right to delete is real and observable.
- **KVKK Decision 2025/2120** (no photocopying guest IDs): supported via optional `id-flow` skill that captures structured guest identity data without scanning to image. Not a sales lead, but quietly resolved.

---

## 14. Roadmap

| Phase | Window | Scope | Definition of done |
|---|---|---|---|
| **MVP** | Month 1–2 | UC-H1, UC-H3 (TR + EN only) | 1 design partner live in Kapadokya, owner reports daily briefing + WhatsApp replies useful |
| **V1** | Month 3–4 | UC-H2, UC-H4, UC-H3 adds RU + DE | 5 design partners; first paying customer at ₺50K |
| **V1.5** | Month 5–6 | İstanbul tier-2 expansion; Booking + Expedia connector hardening | 10 paying customers |
| **V2** | Month 7–9 | UC-H5 + Elektraweb PMS API | 20 paying customers; Bodrum tier-3 testing |
| **V2.5** | Month 10–12 | Protel API; Tier-2 languages (ES, IT) | 50 paying customers; first multi-property customer |
| **V3** | Month 13+ | Multi-property mgmt; channel manager partnership; bank API | TBD |

---

## 15. Risks & mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| HotelRunner ships equivalent product | High | High | Speed; partnership conversation in parallel; out-execute on staff-replacement framing |
| ₺50K pricing too high → long sales cycles | High | Medium | Önbüro personeli cost anchor framing; design partner program for case studies |
| WhatsApp Business approval delays | Medium | Medium | Pre-stage sandbox number; assist with Meta verification |
| Boutique owners don't trust AI on guest messages | Medium | High | "Never auto-send" default; review-queue UI; trust-building period |
| PMS integration painful per customer | High | Medium | CSV-import MVP; defer API until V2; build adapter per vendor not per customer |
| Kapadokya beachhead too small (~250 properties) | Medium | Medium | Plan İstanbul tier-2 from Month 6, not Month 12 |
| Sales cycle ≫ runway | Medium | Critical | Annual prepay incentive; design partner discount for fast close |
| Inference cost overruns customer ACV | Medium | Medium | Per-customer monthly cap; cheap-model demotion when cap approached (`ARCHITECTURE.md` §14 q4) |

---

## 16. Competitive map

| Competitor | What they do | Where we beat them | Where they beat us |
|---|---|---|---|
| HotelRunner | Channel mgr + PMS + AI Review Center + Autopilot pricing | Staff-replacement framing; multi-channel guest comms; no setup fees | Incumbent, 64K accommodations, integrated stack |
| Heyhotel AI | AI hotel tech, Turkish-NLP-first | "AI Asistan" positioning is sharper than "AI hotel tech" | Already in market, claims 500 properties target |
| Elektraweb | PMS leader (5,000+ properties) | Not our category; we sit alongside | Distribution moat in Antalya / coast |
| Protel A.Ş. | Oracle Hospitality partner | Not our category | Mid-market dominance |
| Butiksoft | Brand-aligned for boutique | We're an asistan, they're a PMS | Owns the "butik" Google search term |
| Cloudbeds | Global cloud PMS, partnered with Protel TR | Not our category | International capital, scale |
| Booking Property Tools | Free baseline | Multilingual guest comms not free | Free; ubiquity |
| ChatGPT / generic LLM | Owner-rolled DIY chatbot | Integrated to PMS + OTA + WhatsApp; daily briefing | Free / cheap |

**Positioning rule:** any sales conversation that drifts into "vs. HotelRunner" is a category-creation conversation. Reframe to "vs. hiring an additional front-office staffer" — that's the comparison we win.

---

## 17. Distribution & GTM

**Channels (priority order):**

1. **Founder-led outbound** to first 20 Kapadokya boutique owners (LinkedIn + Instagram + warm intros)
2. **POYD** (Professional Hotel Managers — ~800 members) — speaking slots, sponsor a regional gathering
3. **Kapadokya Otelciler Derneği** — peer-network WhatsApp group; one reference customer = 5 inbound demos
4. **EMITT** (İstanbul, Ocak 2027) — buying window perfect for Kapadokya + İstanbul; book a booth aligned to design partner launch
5. **Travel Turkey İzmir** (Aralık) — secondary
6. **TUROB** — for İstanbul tier-2 expansion (Month 6+)
7. **Referral program** — €1,000 credit per referred signed customer

**Anti-channel:**
- Cold email at scale — Turkish boutique owners don't read cold email
- Paid Google ads on "otel yazılım" keywords — we lose the framing battle to HotelRunner/Elektraweb
- Trade shows outside hospitality — irrelevant

---

## 18. Open questions

1. **Auto-send default for FAQ messages: on or off?** Customer-by-customer or platform default? — Test in design partner program.
2. **Brand voice training data minimum:** how many historical reviews / messages do we need from a hotel before draft quality is acceptable? — Hypothesis: 50 historical responses + a 1-page brand brief.
3. **HotelRunner partnership: pursue or compete?** — Open. Recommend competitive for first 12 months, revisit at Month 12 with leverage from customer base.
4. **Pricing in foreign currency:** some boutiques charge in EUR. Do we offer EUR billing? — Probably not V1; complicates accounting.
5. **What happens off-season for Bodrum properties on annual contracts?** — Some properties close Nov–Mar. Pause + resume vs. discounted full-year? — Survey in design partner intake.
6. **Multi-property owner with mixed verticals (hotel + restaurant)?** — V3 problem; document but don't solve V1.

---

## 19. References

- `docs/ARCHITECTURE.md` — shared platform model
- `docs/PRD-acente-asistani.md` — sibling product, separate ICP, same platform
- `skills/*.md` — current general SME skills (to be moved to `general/skills/`)
- Komtaş Tourism vertical brief (research, 2026-05-19)
- "9 biggest startup ideas" — Greg Isenberg / Jonathan Courtney, May 2026 (source for AI-as-staff-replacement frame; adapted to "Asistan" for Turkish market — "junior" dropped as culturally off)
