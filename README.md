# MarketPulse - Cross-Platform Financial Market Intelligence

**MarketPulse** is a complete, production-ready stock market suite designed for academic presentation and technical defense. It consists of two client applications sharing the same financial brand identity, design tokens, color rules, and data models:

1. **Flutter Mobile Application** (`mobile_app/`): 8 native screens built with Dart and Flutter Material 3, incorporating native geolocation, real-time quotes, `fl_chart` visualizers, and portfolio tracking.
2. **Web Application** (`web_app/`): 7 responsive pages built with HTML5, CSS3, Bootstrap 5, Vanilla JavaScript, Chart.js, and PHP API endpoints.

---

## Quick Start Guide

### 1. Running the Web Application
Requirements: PHP 8.0+

```bash
# Navigate to project root
cd "f:\Stock market app"

# Start the built-in PHP development server on port 8000 (accessible locally & via Wi-Fi)
php -S 0.0.0.0:8000 -t web_app
```
Open your browser at: **[http://localhost:8000](http://localhost:8000)** (or **[http://127.0.0.1:8000](http://127.0.0.1:8000)**)

#### Available Web Pages:
- `index.php`: Home overview, country market detection, major indices, top gainers/losers, news feed.
- `markets.php`: Market snapshot, country switching, real-time table filtering, green/red trend badges.
- `stock.php?symbol=SAP`: Interactive Chart.js multi-range charts (`1D`, `1M`, `3M`, `1Y`), key statistics, historical table.
- `auth.php`: Tabbed Sign In and Registration with validation.
- `portfolio.php`: Portfolio valuation, Chart.js asset allocation doughnut, holdings CRUD actions.
- `pro.php`: Pro membership tier comparison and simulated checkout.
- `search.php`: Multi-parameter search across companies, tickers, and country markets.

---

### 2. Running the Flutter Mobile Application
Requirements: Flutter 3.16+, Dart 3.2+

```bash
# Navigate to mobile_app
cd "f:\Stock market app\mobile_app"

# Verify dependencies and code analysis
flutter analyze

# Run on connected device, emulator, or Windows desktop
flutter run
```

#### Included Mobile Screens:
- **M1 (Splash)**: Brand logo, location permission check, automatic country market setup.
- **M2 (Home)**: Location greeting, primary market card, horizontal major indices, top movers, news cards.
- **M3 (Markets)**: Live search, country market selector, listed equities with directional arrows.
- **M4 (Stock Detail)**: Real-time price hero, range selector (`1D`, `1W`, `1M`, `3M`, `1Y`), `fl_chart` line chart, key stats, historical table, and **"View detailed charts on Web"** launcher.
- **M5 (Auth)**: Sign In / Create Account with error feedback.
- **M6 (Portfolio)**: Total valuation, today's P/L calculation, positions list, and Add Holding modal.
- **M7 (Pro)**: Value propositions, €9.99/mo plan, simulated checkout dialog with activation state.
- **M8 (Settings)**: Manual country selection fallback, currency switcher (`EUR`, `USD`, `GBP`, `INR`), about dialogue.

---

## Directory Structure
```text
f:\Stock market app\
├── plan.md                       (Tracked master plan with completed ✅ points)
├── README.md                     (This file)
├── documentation/
│   ├── ARCHITECTURE.md           (Detailed architectural diagrams & data flows)
│   ├── EXAM_DEFENSE_QA.md        (Answers for the 15-minute exam Q&A defense)
│   └── WIDGET_TREE.md            (Flutter widget hierarchy trees)
├── figma/
│   ├── design_tokens.json        (Color palette, typography, spacing tokens)
│   └── wireframes_overview.md    (UI wireframe specifications)
├── mobile_app/                   (Flutter / Dart mobile project)
│   ├── pubspec.yaml
│   ├── assets/
│   └── lib/
└── web_app/                      (PHP / HTML5 / CSS3 / Vanilla JS web project)
    ├── config/config.php
    ├── api/                      (stock.php, history.php, search.php, currency.php, news.php)
    ├── assets/                   (css/, js/, images/, icons/)
    ├── includes/                 (header.php, footer.php)
    └── [7 primary pages]
```

---

## Technology Compliance Checklist
- [x] **No disallowed frameworks used in Web**: Strictly Vanilla JS, Bootstrap 5, CSS3, HTML5, PHP, and Chart.js.
- [x] **No website CMS used**: Built from clean source code.
- [x] **Location Detection**: `geolocator` on mobile, `navigator.geolocation` on web, with graceful manual fallback.
- [x] **Red / Green Language**: Positive prices/gains in `#16A34A` (Green), negative in `#DC2626` (Red).
- [x] **Offline Resilience**: Built-in fallback cache ensures reliable presentation even without internet access.
