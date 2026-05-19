# PRD — Acente Asistanı

**Product codename:** `acente-asistani`
**Tagline:** *AI Rezervasyon Asistanı for inbound DMCs and tour operators in Türkiye*
**Status:** Draft v1 · **Owner:** Product · **Last updated:** 2026-05-19

---

## 1. Summary

Acente Asistanı is a managed AI agent that performs the reservations / operations work for **mid-size inbound DMCs** (Destination Management Companies) and **tour operators** operating in Türkiye. It runs on the shared Hermes-based platform (see `ARCHITECTURE.md`) with the `modules/acente/` vertical pack enabled.

It does six things:

1. Reads inbound group inquiry emails in EN / DE / FR / AR / RU and drafts a multi-day itinerary + price within 5 minutes
2. Triages and drafts replies to WhatsApp inquiries (where the majority of Turkish DMC inquiries actually arrive)
3. Reads operator's own Google Reviews + post-tour survey emails and produces a monthly Friction Map identifying recurring operational issues
4. Follows up on un-quoted and stale quotes automatically; tracks conversion funnel
5. Tracks multi-currency package economics — TRY volatility against EUR / USD / GBP supplier costs and quoted prices
6. Synthesizes Google Trends + TGA monthly statistics into a quarterly origin-market pulse for trade fair and outreach planning

It does **not** do booking confirmations to suppliers, payments, visa processing, contract negotiation, or back-office accounting. We sit on the front end of the operator's workflow, where speed and language coverage matter most.

This product builds on the planning artefact `usecasesv3cleandata.html` (uploaded 2026-05-19) with explicit additions for WhatsApp, Russian-language coverage, KVKK DPA template, and success metrics.

---

## 2. Problem & opportunity

Turkish inbound DMCs are caught in a structural squeeze:

- **Inquiry volume is high, agents are scarce.** A mid-size inbound DMC at peak season receives 40–100 group inquiries per week. Each complex quote takes a reservations agent 2–4 hours: read the brief, check supplier availability, draft a multi-day itinerary, price it, write the reply in the inquiry language. Slow replies lose groups. Operators know it. They can't hire faster than the inbox grows.
- **Multilingual cost is real.** Russian (3.9M visitors 2024), German (3.5M), UK, plus Gulf Arabic, French, Spanish, increasingly Chinese and Korean. A reservations team that covers 5+ languages well is expensive and rare.
- **Channel fragmentation.** Inquiries arrive via email, WhatsApp, partner portal, agency aggregators. No single inbox. No single review surface. Decisions made on tribal memory, not pattern data.
- **OTA disintermediation.** Türsab filed lawsuits against Airbnb / Booking / Expedia in January 2026; the segment is fighting back. Operators that compete on **service speed + multilingual quality + tailored itineraries** can defend margin. Operators that don't, won't.

There is no integrated AI agent product targeting Turkish inbound DMCs today. International AI-native travel-planning startups (Mindtrip, Layla, GuideGeek) are B2C consumer-facing, not B2B operator tools. Travel Studio, TourPlan, TUI Mintrip are workflow / inventory tools, not agents.

**Window:** 12–18 months before a TourPlan or Travel Studio bolts AI onto their existing stack. After that, incumbency wins.

---

## 3. ICP — Ideal Customer Profile

### Primary target

| Attribute | Value |
|---|---|
| Operator type | Inbound DMC (incoming tour operator) |
| Türsab classification | A-grubu (full-service) primary; B-grubu (wholesale) secondary |
| Team size | 5–30 employees, of which 2–8 in reservations |
| Annual inquiry volume | 2,000–10,000/year (peak ~500/month) |
| Annual gross handled value | ₺50M–500M ($1.5M–15M) |
| HQ location | İstanbul (primary), Antalya, Kapadokya |
| Decision maker | Owner / CEO (60%) or Operasyon / Rezervasyon Müdürü (40%) |
| Existing stack | Outlook/Gmail + WhatsApp + Excel + (some) Travel Studio / TourPlan / proprietary booking sheet |
| Source markets served | At least 3 of {EN, DE, FR, AR, RU, ES, IT, JP, KR, ZH} |
| Türsab membership | Yes (regulatory baseline) |

### Realistic top-of-funnel

- Total Türsab members: ~10,000–12,000 (mostly A-grubu)
- Filtered to inbound DMCs: ~300–500 operators
- Filtered to ICP (5–30 employees, multilingual, growth posture): ~150–250 operators
- 12-month land target: 30–40 paying customers

### Tier-2 expansion (after first 15 paying customers)

- **Outbound tour operators** (Turkish operators selling international packages to Turkish customers) — Jolly Tur, Setur, ETS, Tatil Budur scale. Different ICP, similar product surface.
- **MICE operators** — Meetings, Incentives, Conferences, Exhibitions. Higher ACV, longer cycles.
- **Türsab association deal** — preferred AI vendor distribution. Strategic, not tactical (see §17).

### Explicitly excluded V1

- **A-grubu walk-in agencies < 5 employees** — ACV ceiling too low (₺100–250/mo realistic, breaks our pricing model)
- **Outbound-only agencies** — different workflow, different supplier ecosystem; V2
- **Pure ticketing agencies** — bilet satışı businesses; not our problem space
- **OTA resellers without their own product** — they don't generate itineraries; we don't help

---

## 4. Buyer & user

**Buyer:** Owner / CEO (smaller DMCs) or Operasyon Müdürü (larger DMCs). Buying decision typically family / partner consultation but software < ₺100K/year is normally owner-decided.

**Primary users:**
- Reservations agents (read drafts, edit, send)
- Operasyon Müdürü (monthly Friction Map, conversion dashboard)
- Owner (weekly conversion + currency review; daily WhatsApp summary)

**Champion vs. blocker:**

| Persona | Stance | How we win |
|---|---|---|
| Owner | Champion | Conversion uplift + speed → revenue story |
| Operasyon Müdürü | Champion | Workload reducer, observability into team |
| Senior reservations agent | Mixed — afraid of replacement | "Asistan" positioning + their edits become training data → they remain senior, AI is the asistan |
| Junior reservations agent | Mixed | Frame as their personal assistant, not their replacement |
| Accountant | Neutral / positive | Currency tracking helps margins |

---

## 5. Positioning

**Headline:** *Bir rezervasyon personelinin yaptığı işi, 5 dilde, 5 dakikada yapar. Ayda ₺75K.*

**Anchor comparison:**

| | Rezervasyon personeli (yeni alım) | Acente Asistanı |
|---|---|---|
| Aylık maliyet (yüklü) | ₺40,000–80,000 | ₺75,000 |
| Çalışma süresi | 8 saat / gün | 24 saat / gün |
| Diller | 1–2 | EN + DE + FR + AR + RU + TR (V1) |
| Inquiry başına yanıt süresi | 2–4 saat (basit) / 1 gün (komplex) | 5 dakika |
| Akşam / hafta sonu inquiry kaybı | Yüksek | Sıfır |
| Para birimi takibi | Manuel, hatalı | Anlık, hatasız |

**Pozisyonlama testi:**
"Acente Asistanı her gelen group inquiry'sini 5 dakikada okur, müşterinin dilinde çok günlük itinerary çıkarır, fiyatlandırır, rezervasyon ekibine onay için yollar."

**Buying triggers:**

1. *"Akşam gelen Almanca sorgulara cevap veremiyoruz, ertesi sabah müşteri kapanmış oluyor"* — UC-D1 + UC-D2
2. *"Rusça sorgular geliyor, agent maaşı veremiyoruz çevirmen tutuyoruz"* — UC-D1
3. *"Quote yolladık, müşteri sessiz; takip eden yok"* — UC-D5
4. *"Bir tur 3 ay sonra, tedarikçi EUR fatura kesecek, kur değişti — marj eridi"* — UC-D6
5. *"Geçen sezon hangi rehber kötü gitti, hangi otel sorunluydu — kimse sistemli hatırlamıyor"* — UC-D3

---

## 6. Use cases

The first three use cases (UC-D1, UC-D3, UC-D4) build on the v3 planning artefact (`usecasesv3cleandata.html`) which already specified clean data sources and a build order. The additions (UC-D2, UC-D5, UC-D6) come from research findings in this engagement.

### UC-D1 — Inquiry-to-Itinerary Automation *(MVP)*

**Trigger:** Inbound group inquiry email arrives at the operator's monitored inbox.

**Inputs:**
- Gmail / Outlook OAuth (operator's own inbox)
- Vault `modules/acente/catalog.md` — operator's tour catalog (uploaded as Google Sheet template; PDF accepted as best-effort)
- Vault `modules/acente/supplier-prices.md` — current supplier rate sheets
- Vault `modules/acente/itinerary-templates/` — operator's house itinerary patterns

**Action:**
- Detect inquiry language (EN/DE/FR/AR/RU/TR)
- Extract: dates, group size, origin market, stated interests, accommodation preference, budget signals
- Match to closest operator catalog products + suggest custom adjustments
- Generate multi-day itinerary in inquiry language using operator's house style
- Price it from supplier rate sheets in inquiry currency (with TRY tracking)
- Draft email reply

**Output:**
- Itinerary draft + price + draft email — all queued in agent review screen within 5 minutes
- **Never auto-send.** Agent reviews, edits, sends.
- Vault entry per inquiry — full thread + intermediate steps logged

**Success metrics:**
- Median draft latency: < 5 minutes from inquiry receipt
- Draft acceptance rate by agent (with ≤ 3 edits): ≥ 70% after Week 4
- Quote conversion rate uplift: ≥ 15% in first 90 days vs. pre-product baseline
- Off-hours coverage: 100% of inquiries received 18:00–08:00 have a draft ready by 09:00

**Critical rule:** No auto-send — ever. Reservation correctness has compound financial consequences.

---

### UC-D2 — WhatsApp Inquiry Triage *(MVP)*

**Trigger:** Inbound WhatsApp message to operator's Business number — including agent-to-DMC inquiries from foreign agencies.

**Inputs:**
- WhatsApp Business API gateway
- Same catalog + templates as UC-D1
- Vault `modules/acente/agents/` — known foreign-agency contacts (for B2B inquiries)

**Action:**
- Classify message: new inquiry / follow-up on existing quote / booking confirmation / operational question / out-of-scope
- For new inquiries → run UC-D1 in WhatsApp-message-shaped format
- For existing-quote follow-ups → look up quote, draft response with status
- For operational questions → route to appropriate human (operasyon / muhasebe)
- Multilingual auto-greeting in source language when no agent has responded within 30 seconds during business hours, or any time off-hours

**Output:**
- Draft replies in agent review queue
- Acknowledgement auto-message in customer language ("teşekkürler, ekip arkadaşımız 1 saat içinde dönecek")
- Vault thread linkage to email correspondence (same inquiry across channels)

**Success metrics:**
- WhatsApp acknowledgement latency: < 1 minute, 99% of messages
- Reply draft latency: < 5 minutes business hours, < 30 minutes overnight
- Cross-channel deduplication accuracy: ≥ 90% of WhatsApp + email pairs from same customer linked correctly

**Why this matters (added beyond v3 doc):** for Turkish DMCs, 30–50% of inquiries arrive on WhatsApp, not email. The v3 doc focused on email; this UC closes that gap.

---

### UC-D3 — Post-Tour Friction Map *(V1)*

**Trigger:** Monthly during peak season (Apr–Oct), quarterly off-season. On-demand pre-season planning meeting.

**Inputs:**
- Google Business Profile API — operator's own reviews (clean data, OAuth)
- Gmail API — post-tour survey emails (operator-tagged label, scoped OAuth)
- Vault `modules/acente/tours/` — tour product catalog with supplier mapping
- Vault `modules/acente/suppliers/` — list of hotels, guides, transfer companies

**Action:**
- Aspect-based sentiment across reviews + surveys
- Map each complaint / praise point to: tour product, tour day, supplier (hotel, guide, restaurant, transfer co.)
- Detect recurring patterns: ≥ 3 mentions of same issue in 90-day window
- Track trend direction: rising vs. falling vs. stable

**Output:**
- Monthly (peak) / quarterly (off-peak) Friction Map dashboard widget
- WhatsApp digest to operasyon müdürü
- Vault entry `modules/acente/friction-map.md` with full pattern detail
- Auto-generated supplier scorecard suggestions

**Success metrics:**
- Friction Map identifies ≥ 1 actionable operational issue per cycle
- Operator response: at least 1 supplier conversation per quarter tied to Friction Map evidence
- Trend prediction accuracy: when Friction Map flags rising trend, issue should recur in next cycle ≥ 70% of the time

**Departs from v3 doc:** cadence increased to monthly during peak (was quarterly). Same data sources, same engine, just runs more often when it matters.

---

### UC-D4 — Origin Market Pulse *(V2 — deferred from MVP)*

**Trigger:** Monthly synthesis; on-demand pre-trade-fair planning.

**Inputs:**
- Google Trends Official API (launched July 2025) — country-level search interest for Turkey-travel keywords. Quota and ToS verified before build.
- TGA / Kültür Bakanlığı public monthly visitor statistics
- Vault `modules/acente/origin-markets.md` — operator's historical source market split

**Action:**
- Synthesize search-intent trends per origin market across 12+ destinations within Türkiye
- Cross-reference with arrival statistics to identify rising vs. lagging markets
- Highlight outliers — e.g., "UK Cappadocia search +28% MoM, no corresponding arrival uplift yet — early signal"

**Output:**
- Monthly one-page heat map dashboard + PDF
- Trade fair recommendation list for next quarter

**Success metrics:**
- Heat map directly cited in at least 1 trade fair budget decision per quarter

**Why V2:** the v3 planning marked this as "verify Google Trends API quota and ToS first." That gate hasn't closed. Without it, this UC is speculative. The TGA parser is cheap and can ship in Week 2 regardless (data ingestion only; product UI later).

**Fallback path:** SerpAPI Google Trends wrapper at ~$100/month if official API quota is inadequate.

---

### UC-D5 — Quote Follow-up & Conversion Tracking *(V1)*

**Trigger:**
- 48 hours after quote sent with no customer reply
- Daily digest of stale quotes (> 7 days no response)
- On-demand: "convert rate son 30 gün"

**Inputs:**
- All UC-D1 + UC-D2 quote history
- Email / WhatsApp thread state

**Action:**
- Detect quotes with no customer response
- Draft a polite follow-up in customer language
- Track funnel: inquiry → quote → revised quote → booked → cancelled
- Quarterly conversion rate by source market, language, tour product, agent

**Output:**
- Draft follow-up messages in agent queue
- Conversion funnel widget on dashboard
- Monthly performance summary to owner

**Success metrics:**
- Follow-up draft acceptance ≥ 80%
- Conversion rate uplift on stale quotes: ≥ 10% (some otherwise-lost inquiries get re-engaged)

---

### UC-D6 — Multi-currency Kur Yönetimi *(V1)*

**Trigger:** Daily 09:00 (post-TCMB rate publication); on-demand "kur durum".

**Inputs:**
- TCMB daily rates (public, no auth)
- Vault `modules/acente/supplier-prices.md` — supplier rates in their currency
- Vault `modules/acente/quotes/` — quotes outstanding, in their currencies
- Vault `modules/acente/booked/` — booked tours with payment schedule

**Action:**
- Calculate current TRY-margin for each outstanding quote (supplier EUR cost vs. TRY quoted price)
- Flag quotes where margin has dropped below threshold due to TRY weakening
- For booked tours, project supplier payment day's TRY cost vs. customer payment day's TRY received
- Recommend hedging actions for large exposures

**Output:**
- Daily WhatsApp summary to owner — outstanding exposure in millions of TL
- Dashboard widget: currency exposure timeline
- Alert when any single quote's margin falls below threshold (e.g., < 8%)

**Success metrics:**
- ≥ 95% of outstanding TRY-margin exposure visible on dashboard daily
- Margin-erosion alerts fire ≥ 24 hours before they would have been noticed manually

**Why this is essential in Türkiye:** TRY volatility eats DMC margins constantly. Manual tracking in Excel breaks down at >50 outstanding quotes. This is the use case that operators don't realise they need until they see it work once.

---

## 7. Out of scope (explicitly NOT V1)

| Feature | Why excluded |
|---|---|
| Supplier booking confirmations | Tedarikçi'ye otomatik onay göndermek operasyonel sorumluluk anlamına gelir; V1 değil |
| Payment processing | iyzico / PayU territory; we don't move money |
| Visa application support | Bürokrasi-heavy; not our problem space |
| Outbound package selling to Turkish customers | Different ICP (outbound) — V2 |
| MICE event management | Different workflow — V2 |
| Direct competitor pricing intelligence | Per v3 planning: legal risk on Viator / GYG scraping. Deferred behind legal opinion. |
| Social media posting / marketing automation | Different product surface |
| CRM (full pipeline beyond conversion tracking) | V1 only tracks quote-stage conversion; not full CRM |
| Multi-tenant agency network management | If a customer has multiple legal entities, V1 ships one slug each |
| Accounting integration | Logo / Mikro / Netsis — V3 if customer demand |

---

## 8. Success metrics

### Customer-level

| Metric | Target |
|---|---|
| Inquiry-to-draft median latency | ≤ 5 minutes |
| Draft acceptance rate (≤ 3 edits) | ≥ 70% by Week 4 |
| WhatsApp ack latency | < 1 min (99th percentile) |
| Off-hours inquiry coverage | 100% drafted by 09:00 next morning |
| Quote conversion uplift | ≥ 15% in first 90 days |
| Currency margin alert pre-emption | ≥ 24 hours before manual detection |
| Owner WhatsApp engagement | ≥ 1 daily interaction average |

### Business-level

| Metric | Target Month 6 | Target Month 12 |
|---|---|---|
| Paying customers | 5 | 25 |
| Logo retention (12-mo) | – | ≥ 90% (higher than hotel; sticky workflow) |
| Net ACV | ₺75K | ₺80K |
| Pipeline velocity | 12–20 weeks (DMCs decide faster than boutique owners) | Same |
| Türsab partnership engagement | Initial meeting held | Pilot agreement signed |
| Referenceable customers | 2 case studies | 8 case studies |

---

## 9. Pricing

| Tier | Aylık | Yıllık | Kapsam |
|---|---|---|---|
| Design Partner (first 3) | ₺35,000 | ₺420,000 | Tüm UC, case study karşılığı |
| Launch | ₺75,000 | ₺900,000 | Tüm UC, 6 dil, standart SLA |
| Yüksek hacimli (>500 inquiry/ay) | ₺100,000 | ₺1,200,000 | +ek dil, öncelikli destek |
| Türsab member discount | %15 indirim | – | Eğer Türsab partnership kurulursa |

**Setup fee:** ₺25,000 one-time (operatör catalog'unun template'e yüklenmesi dahil). Waived for design partners.

**Currency note:** TL-fixed pricing with quarterly review clause. Customers serving USD/EUR markets sometimes prefer USD-denominated; offer at owner's discretion not platform default.

---

## 10. Architecture mapping

```
modules/acente/
├── skills/
│   ├── inquiry-to-itinerary.md          ← UC-D1
│   ├── whatsapp-inquiry-triage.md       ← UC-D2
│   ├── post-tour-friction-map.md        ← UC-D3
│   ├── origin-market-pulse.md           ← UC-D4 (V2)
│   ├── quote-followup-conversion.md     ← UC-D5
│   └── multi-currency-kur.md            ← UC-D6
├── connectors/
│   └── manifest.yaml
│       required:
│         - gmail-or-outlook
│         - whatsapp-business
│         - gbp
│         - tcmb-rates              # public TCMB rates, no auth
│       optional:
│         - google-trends-official
│         - tga-public-stats
│         - travel-studio
│         - tourplan
├── vault-schema/
│   ├── operator.md                     # company profile
│   ├── catalog.md                      # tour products
│   ├── supplier-prices.md
│   ├── itinerary-templates/
│   ├── inquiries/
│   ├── quotes/
│   ├── booked/
│   ├── tours/                          # per-tour-product records
│   ├── suppliers/                      # hotels, guides, transfer cos
│   ├── agents/                         # foreign agency contacts (B2B)
│   ├── friction-map.md
│   ├── origin-markets.md
│   └── kur-takibi.md
└── widgets/
    ├── inquiry-queue.html.partial
    ├── conversion-funnel.html.partial
    ├── friction-map.html.partial
    ├── origin-market-heatmap.html.partial
    └── currency-exposure.html.partial
```

**Profile example:**

```toml
[customer]
slug = "istanbul-inbound-dmc"
display_name = "İstanbul Inbound DMC"
domain = "panel.istanbulinbound.com.tr"

[modules]
core    = true
general = true
acente  = true

[modules.acente]
languages = ["tr", "en", "de", "ru", "fr", "ar"]
markets   = ["DE", "RU", "GB", "FR", "SA", "AE", "ES"]
currencies = ["TRY", "EUR", "USD", "GBP"]
team_size = 12
peak_months = [4, 5, 6, 7, 8, 9, 10]

[connectors]
gmail            = "credentials/gmail.json"
whatsapp_business = "credentials/whatsapp.json"
google_business  = "credentials/gbp.json"
```

---

## 11. Data sources & integrations

| Source | Method | Status | Notes |
|---|---|---|---|
| Gmail / Outlook | OAuth (operator) | **MVP required** | Read scope on inquiry label |
| WhatsApp Business API | Meta Business API | **MVP required** | 2–4 week approval |
| Google Business Profile | OAuth (operator) | **V1 required** | 14-day approval |
| TCMB daily rates | Public XML feed | **V1 required** | No auth |
| Operator tour catalog | Google Sheet template + PDF best-effort | **MVP required** | Custom upload + parsing |
| Supplier rate sheets | Excel / PDF upload | **V1 required** | Manual maintenance V1 |
| Google Trends Official API | Apply for access | V2 | Verify quota + commercial ToS |
| TGA monthly statistics | Public PDF download | V2 | 4–6 week lag baseline |
| Travel Studio | API (if customer subscribes) | V3 | Read-only |
| TourPlan | API | V3 | Read-only |
| TripAdvisor B2B Content API | Not available | **Dropped** | Explicitly prohibited for B2B |
| Viator / GYG public scraping | Not available | **Dropped** | Legal risk; see v3 planning |
| Skyscanner affiliate | Apply | V3 | 4–8 week approval, not critical |

**MVP minimum data to ship:** Gmail/Outlook + WhatsApp Business + tour catalog upload + TCMB rates. Everything else is V1+.

---

## 12. Onboarding flow

Target: 7 business days from contract to live.

| Day | Operator does | We do |
|---|---|---|
| Day 0 | Sign contract + KVKK DPA | Provision VM, generate profile |
| Day 1 | Provide tour catalog (Google Sheet template or PDF), supplier rate sheets, brand-voice samples | Build operator vault, ingest catalog |
| Day 2 | Grant Gmail/Outlook OAuth on inquiry inbox | Set up Gmail watcher, configure label filter |
| Day 3 | Provide WhatsApp Business number + Meta docs | Submit WhatsApp API application |
| Day 4 | Grant GBP manager access | Configure GBP for UC-D3 |
| Day 5 | Provide 20 historical inquiries + their actual responses | Train brand voice + draft quality baseline |
| Day 6 | Walk through draft outputs, set acceptance thresholds, define escalation rules | Tune skills, finalise dashboard, test currency tracking |
| Day 7 | Go-live + 1-week observation | Daily customer success ping; monitor accuracy |

**Catalog upload reality:** operators have catalogs in PDF, Word, Notion, Trello, Excel — every format imaginable. We accept Google Sheet template (canonical, structured), PDF (best-effort parsing, may need manual review), Word (best-effort). Onboarding includes 1 hour of customer success time to validate the parsed catalog against the operator's mental model.

---

## 13. KVKK & data governance

Inherits the platform stance (`docs/ARCHITECTURE.md` §12). DMC-specific additions:

- **Müşteri verisi:** name, contact, passport copy (for visa), travel insurance details, payment confirmation. Highly sensitive — encrypted vault, PII redaction at KV Router, audit trail.
- **Agent / supplier verisi:** foreign agencies' contacts, supplier credentials. Same encryption.
- **GDPR overlap:** for EU-origin customers, processing may engage GDPR. DPA template covers both KVKK and GDPR — single document for V1.
- **Türsab partnership angle:** if pursued, our KVKK DPA template can be Türsab-reviewed and pre-approved as a member benefit, dramatically reducing per-member onboarding friction.

---

## 14. Roadmap

| Phase | Window | Scope | Definition of done |
|---|---|---|---|
| **MVP** | Month 1–2 | UC-D1 (EN + DE only), UC-D2 (TR + EN only) | 1 design partner, owner reports speed + reply quality acceptable |
| **V1** | Month 3–5 | UC-D1 adds FR / AR / RU; UC-D3; UC-D5; UC-D6 | 3 design partners; first paying customer |
| **V1.5** | Month 6–7 | Catalog parsing hardening; Türsab pilot kickoff | 10 paying customers |
| **V2** | Month 8–10 | UC-D4; multi-language Tier-2 (ES, IT, JP, KR, ZH) | 20 paying customers |
| **V2.5** | Month 11–12 | Travel Studio + TourPlan read-only integrations | 30 paying customers |
| **V3** | Month 13+ | Outbound segment exploration; MICE module pilot | TBD |

---

## 15. Risks & mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Catalog upload format chaos delays onboarding | High | Medium | Canonical Google Sheet template + 1 hr CS time per customer |
| Quote-correctness errors damage operator reputation | Medium | High | **Never auto-send.** Trust UI; review queue first |
| Multilingual quality below human standard | Medium | High | Per-language eval set; sample QA monthly; "draft, not send" framing |
| WhatsApp Business approval delays | Medium | Medium | Sandbox number for testing during onboarding |
| Travel Studio / TourPlan integration complexity (V2) | Medium | Low | Defer integration to V2.5; CSV/manual import in V1 |
| Türsab partnership longer than 18 months | High | Medium | Direct sales as primary channel; Türsab as optional accelerator |
| TRY collapse impacts customer ACV | Medium | Critical | Quarterly TRY review clause; option for partial USD billing |
| Competitor (Travel Studio + AI) ships first | Medium | High | Hermes architecture lets us ship features faster than a Java-stack incumbent; speed advantage real |
| Inquiry volume spike during peak overruns inference cost | Medium | Medium | Per-customer monthly cap; cheap-model demotion |
| "Asistan" framing tone-deaf in some DMC contexts | Low | Low | "Junior" already dropped after Turkish-cultural feedback; "Asistan" tested with first 5 design partners |

---

## 16. Competitive map

| Competitor | What they do | Where we beat them | Where they beat us |
|---|---|---|---|
| Travel Studio (UK) | DMC reservation + tour management system | AI-native, agentic | Incumbent, 30 years, deep workflows |
| TourPlan (NZ) | Same category, more global | Same | Same |
| TUI Mintrip | AI travel planning, B2C | Different audience (we're B2B) | TUI capital |
| Mindtrip / Layla | Consumer AI travel agents | We're operator-facing, they're consumer | Brand awareness |
| Mintrip from TUI | AI travel concierge | We do operator workflows, not consumer planning | Resources |
| GuideGeek | AI travel planning B2C | Same | Brand |
| Native operator-rolled GPT setup | Free, sometimes adequate for single-language | Integrated to inbox, WhatsApp, currency, GBP | Free / cheap |
| HotelRunner (cross-vertical) | They serve hotels not DMCs primarily | Different ICP | They may move into DMC space |
| Salesforce Travel Cloud | Heavyweight CRM with AI | Too expensive, too generic | Brand, IT trust |

**Positioning rule:** stay in "5-minute quote + multilingual + currency" frame. Don't drift into "DMC operating system" — that's a 5-year build we lose. Do one job, very well.

---

## 17. Türsab partnership strategy

The Türsab angle is potentially the highest-leverage move for this product. Türsab:

- Founded 1972, ~388 employees, ~$22M operational budget
- 10,000+ member agencies; ~300–500 inbound DMCs among them
- Already runs TÜRSAB Software + TÜRSAB ROTA for members
- Sued Booking / Expedia / Airbnb in January 2026 → politically aligned with operators competing on quality
- Yapı Kredi partnership for digital transformation

**Two parallel tracks:**

1. **Direct DMC sales** (Track A) — Months 1–12. Founder-led outbound. 30–40 paying customers target.
2. **Türsab association partnership** (Track B) — Months 3–18. Pursue "preferred AI vendor" or "AI Asistan pilot" status. Mechanism: Komtaş existing relationship + our DMC traction as proof.

Track B success would dramatically reduce CAC and unlock the long tail of small DMCs we currently exclude from ICP. But it's not a substitute for Track A — Türsab moves slowly, and we need our own paying customers before they take us seriously.

**Open question:** does Komtaş want to lead the Türsab conversation, or do we?

---

## 18. Distribution & GTM

**Channels (priority):**

1. **Founder-led outbound** to first 20 inbound DMC owners (LinkedIn + warm intros via existing Komtaş Türsab interest)
2. **Türsab events** — congresses, regional meetings; sponsorship + speaking
3. **EMITT** (İstanbul, Ocak) — buying window perfect
4. **POYD / TUROB** — adjacent hospitality networks; secondary
5. **TUI / Pegas / Anex** — foreign tour operator partners can recommend DMCs use our product

**Anti-channel:**
- Generic SaaS Google ads
- Cold mass email
- Hospitality-only trade shows (we're not selling to hotels)

---

## 19. Open questions

1. **Catalog parsing quality:** is the canonical Google Sheet acceptable to operators, or must we accept Word / Notion / PDF natively V1? — Pilot with 3 design partners' real catalogs.
2. **"Asistan" naming:** confirmed after "junior" was rejected as culturally off. Sub-question: does "Asistan" need regional variants (İstanbul vs. Antalya DMCs)? — Test with first 5 conversations.
3. **Türsab partnership ownership:** us or Komtaş? — Decision needed before Month 3.
4. **Quote auto-send threshold:** ever? — Recommend: never V1, revisit after 6 months of trust data.
5. **MICE adjacency:** do MICE operators want the same product or a different one? — Don't research V1; pure focus on inbound leisure DMC.
6. **Multi-currency billing:** TRY-only V1, or USD option from day 1? — Suggest TRY-only V1; revisit by customer demand.

---

## 20. References

- `docs/ARCHITECTURE.md` — shared platform model
- `docs/PRD-otel-asistani.md` — sibling product
- `usecasesv3cleandata.html` — v3 planning artefact (uploaded 2026-05-19)
- Komtaş Türsab account intelligence (research, 2026-05-19)
- Komtaş Tourism vertical brief
- "9 biggest startup ideas" — Greg Isenberg / Jonathan Courtney, May 2026 (source for AI-as-staff-replacement frame; adapted to "Asistan" for Turkish market — "junior" dropped)
