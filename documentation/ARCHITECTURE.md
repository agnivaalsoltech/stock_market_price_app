# MarketPulse Architecture & Technical Specifications

## 1. System Overview
MarketPulse is a financial intelligence ecosystem built as **one product with two client interfaces**:
- **Mobile Client**: Flutter / Dart application providing 8 core views, native geolocation, real-time quotes, fl_chart visualizations, and portfolio tracking.
- **Web Client**: HTML5, CSS3, Bootstrap 5, Vanilla JavaScript, PHP API proxy/endpoints, and Chart.js dynamic visualizations across 7 responsive pages.

```
                    MarketPulse Brand Identity
                         │
        ┌────────────────┴────────────────┐
        │                                 │
   Flutter Mobile                      Web App
   (Dart / Material 3)          (Bootstrap 5 / Vanilla JS)
        │                                 │
    Geolocator                     Navigator Geolocation
        │                                 │
        └────────────────┬────────────────┘
                         │
                 PHP Data Services
              (/api/stock.php, history,
               search, currency, news)
                         │
                 Financial Catalog
              (Germany, USA, UK, India)
```

---

## 2. Web Application Architecture
- **Language**: PHP 8+ backend proxy, HTML5 structure, CSS3 custom tokens, Bootstrap 5 responsive layout grid, Vanilla ES6+ JavaScript.
- **Charts**: Chart.js 4+ with custom linear gradients (Green `#16A34A` for positive momentum, Red `#DC2626` for negative movement).
- **Multi-Currency System**: Global currency selector in header (`EUR`, `USD`, `GBP`, `INR`). Updates DOM elements dynamically via `data-base-price` attributes and triggers `currencyChanged` custom events for chart and portfolio recalculation.
- **Location Detection**: Uses `navigator.geolocation` coordinates with automatic country market mapping (Germany, USA, UK, India) and manual dropdown override.

---

## 3. Mobile Application Architecture
- **State & Service Layer**: Singleton pattern for `LocationService`, `CurrencyService`, `StockApiService`, and `PortfolioService`.
- **Location**: `geolocator` package determines GPS coordinates. If permission is denied or location services are disabled, it gracefully activates the manual country fallback without interruption.
- **Resilience Strategy**: Every API request in `StockApiService` falls back to a normalized local cache if network latency or server downtime occurs.
- **Navigation**: Named routes (`/`, `/home`, `/markets`, `/stock_detail`, `/auth`, `/portfolio`, `/pro`, `/settings`).
- **External Web Trigger**: `url_launcher` enables launching the full web dashboard directly from the mobile stock detail screen.

---

## 4. Normalized Data Models
- **Stock**: `symbol`, `companyName`, `exchange`, `country`, `currency`, `price`, `open`, `high`, `low`, `previousClose`, `change`, `changePercent`, `volume`, `marketCap`, `peRatio`, `week52High`, `week52Low`, `sector`.
- **MarketIndex**: `symbol`, `name`, `price`, `change`, `changePercent`.
- **HistoricalPoint**: `date`, `close`.
- **PortfolioItem**: `id`, `symbol`, `quantity`, `purchasePrice`.
  - Math: $\text{invested} = \text{quantity} \times \text{purchasePrice}$
  - $\text{current} = \text{quantity} \times \text{currentPrice}$
  - $\text{P/L} = \text{current} - \text{invested}$
  - $\text{P/L \%} = (\text{P/L} / \text{invested}) \times 100$
