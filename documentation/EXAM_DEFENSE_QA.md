# MarketPulse: Exam Presentation Defense Q&A Guide

This guide prepares you for the **5-minute presentation** and **15-minute Q&A defense** specified in the exam guidelines.

---

### Q1: Why did you choose Flutter for the mobile app?
**Answer:**
Flutter enables compiling native ARM machine code for both iOS and Android from a single Dart codebase. It provides pixel-perfect UI consistency with Material 3 widgets, high rendering performance (60–120 fps) via the Skia/Impeller engine, and direct access to native platform capabilities like GPS through `geolocator`.

---

### Q2: How does Geolocator work in your mobile app?
**Answer:**
`LocationService` queries `Geolocator.isLocationServiceEnabled()` and checks permissions with `Geolocator.checkPermission()`. If granted, it requests device latitude and longitude via `Geolocator.getCurrentPosition()`. These coordinates are mapped to country market boundaries (e.g. Germany for European latitudes). If the user denies permission, the app does not crash; it smoothly activates the **manual country selection fallback** (defaulting to Frankfurt/Germany).

---

### Q3: How does API data enter the application?
**Answer:**
In the web client, Vanilla JavaScript makes asynchronous `fetch()` calls to lightweight PHP endpoints (`/api/stock.php`, `/api/history.php`, `/api/search.php`). In the mobile client, `StockApiService` makes HTTP requests using the Dart `http` package, deserializes the JSON responses into strongly-typed Dart models (`Stock`, `MarketIndex`, `HistoricalPoint`), and binds them to UI widgets. Both clients implement an offline cache fallback so the app continues working even without an active internet connection.

---

### Q4: How are stock price colors determined?
**Answer:**
Prices and daily changes are compared against zero:
- If $\Delta \text{Price} \ge 0$, the UI assigns positive styling: Emerald Green (`#16A34A`), positive badge background (`#DC2626` / `#DCFCE7`), and an upward arrow indicator (`▲` or `↑`).
- If $\Delta \text{Price} < 0$, the UI assigns negative styling: Ruby Red (`#DC2626`), negative badge background (`#FEE2E2`), and a downward arrow indicator (`▼` or `↓`).
The system guarantees that contrasting colors are never mixed.

---

### Q5: How do the charts work on Web and Mobile?
**Answer:**
- **Web**: Powered by **Chart.js**. The canvas context creates a dynamic linear vertical gradient that shifts from green/red tint down to transparent fill. Time range buttons (`1D`, `1M`, `3M`, `1Y`) trigger AJAX calls to `/api/history.php` and dynamically re-render the chart.
- **Mobile**: Powered by `fl_chart` using `LineChart` and `LineChartBarData` with cubic spline curvature (`isCurved: true`) and area gradient fill.

---

### Q6: How does location determine the displayed country market?
**Answer:**
The location coordinates are converted into the primary national stock exchange:
- Germany $\rightarrow$ XETRA / DAX 40
- USA $\rightarrow$ NYSE / NASDAQ / S&P 500
- United Kingdom $\rightarrow$ LSE / FTSE 100
- India $\rightarrow$ NSE / BSE / NIFTY 50
If location is unavailable or manually overridden, the user selects their country from the dropdown, instantly re-indexing the market view.

---

### Q7: How is PHP used in the web project?
**Answer:**
PHP acts as the backend data provider and API proxy. It normalizes raw market data into standardized JSON structures, computes multi-day historical intervals, simulates intra-day volatility, handles exchange rate calculations, and enforces CORS headers. This complies with the exam rule requiring PHP while avoiding prohibited frameworks like Laravel.

---

### Q8: Why did you choose Chart.js for the website?
**Answer:**
Chart.js is explicitly required by the assignment brief. It is lightweight, renders crisply on HTML5 Canvas across desktop and mobile browsers, supports responsive aspect ratios, and operates completely in Vanilla JavaScript without requiring React, Vue, or Angular.

---

### Q9: How does responsive design work on the website?
**Answer:**
The layout uses Bootstrap 5 responsive grid classes (`col-12`, `col-md-6`, `col-lg-4`, `col-xl-3`) and CSS media queries:
- **Desktop (>1200px)**: 3 to 4 column dashboard layout.
- **Tablet (768px – 1199px)**: 2 column layout with adaptive tables.
- **Mobile (<768px)**: Single column stack, with the top navigation converting into an accessible hamburger menu collapse.

---

### Q10: How is portfolio profit calculated?
**Answer:**
For each position:
$$\text{Invested Value} = \text{Quantity} \times \text{Purchase Price}$$
$$\text{Current Value} = \text{Quantity} \times \text{Current Market Price}$$
$$\text{Profit/Loss} = \text{Current Value} - \text{Invested Value}$$
$$\text{Profit/Loss \%} = \frac{\text{Profit/Loss}}{\text{Invested Value}} \times 100$$
The totals are summed across all positions and updated live when prices fluctuate or currency is switched.

---

### Q11: How does navigation work across both applications?
**Answer:**
- **Web**: Standard clean multi-page URL routing (`index.php`, `markets.php`, `stock.php?symbol=...`, `portfolio.php`, `pro.php`, `search.php`) linked via a global sticky Bootstrap navbar.
- **Mobile**: Flutter `MaterialApp` named routes (`AppRoutes`) with a bottom navigation bar for core screens, drawer menu for secondary screens, and URL launcher to seamlessly transition from mobile to the web version.
