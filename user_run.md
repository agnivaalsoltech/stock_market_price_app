# MarketPulse — User Run Instructions & Execution Guide

This document provides step-by-step instructions on how to run, test, and demonstrate both the **Web Application** and the **Mobile Application** on your computer.

---

## 1. Project Prerequisites & System Requirements

Before running the project, ensure your development environment satisfies the required versions and dependencies for both the **PHP Web Backend** and the **Flutter Mobile Application**.

---

### A. Flutter Mobile App Requirements

| Requirement | Supported / Required Version | Purpose / Notes |
| :--- | :--- | :--- |
| **Flutter SDK** | **`>= 3.16.0`** (Tested on 3.16.x – 3.27.x) | Core UI framework for mobile & desktop builds. |
| **Dart SDK** | **`>= 3.2.0 < 4.0.0`** | Defined in `mobile_app/pubspec.yaml`. |
| **Execution Directory** | `f:\Stock market app\mobile_app` | ⚠️ **CRITICAL:** Always run all `flutter` commands from inside `mobile_app`. Running from the root directory will produce `Error: No pubspec.yaml file found`. |
| **Android Toolchain** | Android SDK 34+, Java JDK 17+, Platform-Tools (ADB) | Required for running on Android emulators or physical Android phones. |
| **Windows Desktop Toolchain** | Visual Studio 2022 with *"Desktop development with C++"* | Required if launching the native Windows desktop target (`flutter run -d windows`). |
| **Web Browser Target** | Google Chrome or Microsoft Edge | Required if launching the browser emulator target (`flutter run -d chrome`). |

#### Verification Commands:
```powershell
# Check Flutter and Dart SDK versions
cd "f:\Stock market app\mobile_app"
flutter --version

# Verify complete environment health
flutter doctor -v
```

---

### B. PHP Web Backend Requirements

The web application and mobile REST API are powered by **PHP 8**. No Apache, Nginx, XAMPP, Node.js, or npm build steps are required.

| Requirement | Supported / Required Version | Purpose / Notes |
| :--- | :--- | :--- |
| **PHP Version** | **`PHP 8.0+`** (Tested on PHP 8.4.20) | Required for modern language features (union types, match expressions, nullsafe operator). |
| **Web Server Engine** | Built-in PHP CLI Server | Run with `php -S 0.0.0.0:8000 -t web_app`. |
| **Available Port** | **Port `8000`** (or `8080`) | Ensure port 8000 is open and not occupied by another background process. |
| **Network Interface** | **`0.0.0.0`** binding | Enables simultaneous connections from PC browser, Android emulator (`10.0.2.2`), and physical phones on Wi-Fi. |

#### Required PHP Extensions (check via `php -m`):
- ✅ **`curl`**: Required for live external stock quote ingestion, financial news feeds, and currency exchange rates.
- ✅ **`json`**: Required for encoding and decoding REST API requests/responses with the Flutter mobile client.
- ✅ **`mbstring`**: Required for multi-byte UTF-8 string manipulation and international currency symbols (`€`, `$`, `£`, `₹`).
- ✅ **`openssl`**: Required for secure outbound HTTPS connections to real-time market data providers.
- ✅ **`session`**: Required for simulated authentication, persistent user sessions, and portfolio tracking.
- ✅ **`fileinfo` & `ctype`**: Required for static asset MIME-type resolution and user input validation.
- ℹ️ **`pdo` & `pdo_mysql`**: Optional; available if you choose to attach a MySQL database.

#### Additional Network & OS Configuration for PHP:
1. **Windows Firewall Prompt**: When running `php -S 0.0.0.0:8000 -t web_app` for the first time, Windows Defender Firewall may display an alert. Check **"Private networks"** and click **Allow access**. This allows your physical phone on Wi-Fi to reach the PHP server.
2. **USB Debugging & ADB Reverse** (for physical phone testing over USB cable):
   ```powershell
   adb reverse tcp:8000 tcp:8000
   ```
   This bridges port 8000 so the phone can communicate with `http://127.0.0.1:8000` without requiring local Wi-Fi.

#### Verification Commands:
```powershell
# Verify PHP version
php -v

# Verify required extensions are loaded
php -m
```

---

### C. Web Browser Requirements
- Any modern web browser: **Google Chrome**, **Microsoft Edge**, **Mozilla Firefox**, **Brave**, or **Apple Safari**.
- **JavaScript must be enabled** (HTML5 Canvas, ES6 modules, and Bootstrap 5 interactivity).

---

## 2. How to Run the Web Application

The web project uses **HTML5, CSS3, Bootstrap 5, Vanilla JavaScript, PHP, and Chart.js**.

### Step-by-Step:

1. **Open PowerShell** in the project root folder:
   ```powershell
   cd "f:\Stock market app"
   ```

2. **Start the built-in PHP development server on `0.0.0.0:8000`**:
   ```powershell
   php -S 0.0.0.0:8000 -t web_app
   ```
   > **Why `0.0.0.0:8000` instead of `127.0.0.1:8000`?**  
   > Binding to `0.0.0.0` allows PHP to listen on **all network interfaces simultaneously**:
   > - 💻 **Local PC Browser**: Accessible via `http://localhost:8000` or `http://127.0.0.1:8000`.
   > - 📱 **Physical Phone on Wi-Fi**: Accessible via your PC's Wi-Fi IP (`http://192.168.1.4:8000`).
   > - 🔌 **Connected Phone via ADB**: Accessible via `http://127.0.0.1:8000` after running `adb reverse tcp:8000 tcp:8000`.
   > - 🤖 **Android Emulator**: Accessible via `http://10.0.2.2:8000`.

   *You will see:*
   `[Date] PHP 8.x.x Development Server (http://0.0.0.0:8000) started`

3. **Open your browser** (Chrome, Edge, Firefox, Brave, etc.) and go to:
   👉 **[http://localhost:8000](http://localhost:8000)** (or **[http://127.0.0.1:8000](http://127.0.0.1:8000)**)

---

### What to Explore on the Web Application:

| Page | URL | Key Features to Test |
| :--- | :--- | :--- |
| **W1: Home** | `http://127.0.0.1:8000/index.php` | • Location header & live market status.<br>• Major indices (DAX, MDAX, TecDAX).<br>• Top movers with green/red badges.<br>• Real-time financial news snapshot.<br>• Quick market switcher dropdown. |
| **W2: Markets** | `http://127.0.0.1:8000/markets.php` | • Country filter (Germany 🇩🇪, USA 🇺🇸, UK 🇬🇧, India 🇮🇳).<br>• Real-time company/ticker filter bar.<br>• Direct click on any row to open detailed stock page. |
| **W3: Stock Detail** | `http://127.0.0.1:8000/stock.php?symbol=SAP` | • Interactive **Chart.js** price chart.<br>• Time range buttons (**1D, 1M, 3M, 1Y**).<br>• Key statistics (Open, High, Low, 52W High/Low, P/E, Cap).<br>• 5-day historical price table.<br>• Related news articles with external links. |
| **W4: Auth** | `http://127.0.0.1:8000/auth.php` | • Tabbed **Sign In** and **Create Account** forms.<br>• Field validation (checks email format and password $\ge 6$ chars).<br>• Simulated login session saving to `localStorage`. |
| **W5: Portfolio** | `http://127.0.0.1:8000/portfolio.php` | • Total portfolio valuation & today's P/L.<br>• **Chart.js Asset Allocation Doughnut**.<br>• Holdings table (SAP, BMW, Siemens).<br>• **+ Add Investment** modal to add new stocks with instant math calculation.<br>• Delete button to remove positions. |
| **W6: Pro** | `http://127.0.0.1:8000/pro.php` | • Free Standard vs MarketPulse Pro comparison table.<br>• Pricing (€9.99 / month).<br>• **Upgrade to Pro** simulated checkout modal activating Pro status. |
| **W7: Search** | `http://127.0.0.1:8000/search.php` | • Search by ticker (e.g. `SAP`, `BMW`, `AAPL`, `TSLA`).<br>• Search by company name or country (e.g. `Germany`, `USA`, `India`).<br>• Quick search tags. |

### Global Features: Currency Switching, Dark Mode & Watchlists
1. **Dynamic Currency Switching**: In the top-right navbar, click the **Curr: EUR (€)** dropdown and choose **USD ($)**, **GBP (£)**, or **INR (₹)** to recalculate prices across the entire application in real time.
2. **Dark / Light Mode**: Click the **🌙 / ☀️** toggle button in the navbar to instantly switch between Light Mode and sleek Slate Dark Mode (`#0F172A`).
3. **Custom Watchlist**: Click the star icon (★) next to any stock on the Markets page or Stock Detail page to add/remove it from your watchlist. Use the **⭐ Watchlist** filter button on the Markets page to see only your tracked equities!

---

## 3. How to Run the Flutter Mobile Application

Since your **PHP Web Backend is already running in your first terminal window**, you need to keep that running and launch the mobile app in a **second terminal window**.

### Step-by-Step Instructions:

1. **Open a NEW (Second) PowerShell Window / Terminal Tab**:
   Leave your first terminal with the PHP server running!

2. **Navigate into the mobile app directory**:
   > ⚠️ **CRITICAL DIRECTORY WARNING:**
   > Flutter commands **must** be executed from inside the `mobile_app` folder:
   > ```powershell
   > cd "f:\Stock market app\mobile_app"
   > ```
   > *If you run `flutter run` from the project root (`f:\Stock market app`), Flutter will fail with:*
   > `Error: No pubspec.yaml file found. This command should be run from the root of your Flutter project.`

3. **Launch the Mobile Application**:
   Choose whichever platform you want to test on:

   - 🖥️ **Option A: Windows Desktop Native App (Recommended & Fastest)**
     ```powershell
     flutter run -d windows
     ```
     *This immediately opens a native desktop window of the MarketPulse mobile app on your PC connected to `http://127.0.0.1:8000`.*

   - 🌐 **Option B: Chrome Browser (Mobile Simulator View)**
     ```powershell
     flutter run -d chrome
     ```
     *Press `F12` in Chrome and click the Mobile Device Toggle icon (`Ctrl + Shift + M`) to simulate an iPhone or Pixel screen.*

   - 📱 **Option C: Running on Your Connected Physical Phone (e.g. moto g96 5G)**
     
     If Gradle reports a locked file error from a previous build interruption, first clean the build cache:
     ```powershell
     flutter clean
     ```

     Forward the PC's port 8000 to your phone so `127.0.0.1:8000` works directly on your phone:
     ```powershell
     adb reverse tcp:8000 tcp:8000
     ```

     Launch the app on your connected device:
     ```powershell
     flutter run -d ZN52227W7S
     ```
     *(Or simply run `flutter run` and select `[1]` for `moto g96 5G`).*

---

### Step 4: Verify Live Backend Connection in the App

1. When the app opens, tap the **Settings** icon (⚙️ in the top right or open from the left drawer ☰).
2. Scroll to the **"Backend Server (PHP API Synchronization)"** card:
   - The app now defaults to **Wi-Fi / LAN (`http://192.168.1.4:8000`)** with a green `Wi-Fi / LAN (Active)` badge.
   - You can also tap between preset chips:
     - `📡 Wi-Fi / LAN (192.168.1.4:8000) ⭐ Default` (Recommended for physical phone and local devices)
     - `💻 PC / ADB (127.0.0.1:8000)`
     - `📱 Android Emu (10.0.2.2:8000)`
   - The telemetry test runs automatically when opening Settings and displays:
     `Connected (HTTP 200) • Live SAP: €221.20 (x ms)`
3. Now browse the **Home** (M2), **Markets** (M3), and **Stock Detail** (M4) screens — all live stock prices, candlestick OHLCV telemetry, company metadata, news, and exchange rates sync live from your PHP backend!


### What to Explore on the Mobile App:

1. **M1 — Splash Screen**:
   - Displays MarketPulse logo, tagline, and progress indicator.
   - Automatically initializes `LocationService` (attempts GPS lookup; if denied, uses Germany fallback).
   - Automatically loads portfolio positions and routes to Home.

2. **M2 — Home Dashboard**:
   - Header with greeting ("Good morning") and detected country flag & exchange.
   - **Responsive Asset Image Banner (`assets/images/market_hero.png`)**: Built using `OrientationBuilder` so image aspect ratio and layout adapt responsively when device rotates between portrait and landscape.
   - Main market summary card (DAX 18,942.31, +0.76% green/red indicator).
   - Horizontal scrolling cards for major indices.
   - Top movers list (green for gainers, red for losers).
   - Bottom navigation bar: **Home**, **Markets**, **Portfolio**, **Pro**.
   - Left drawer menu with links to all screens.

3. **M3 — Markets & Snapshot**:
   - Country dropdown switcher (switch between Germany 🇩🇪, USA 🇺🇸, UK 🇬🇧, India 🇮🇳).
   - **All Equities | ⭐ Watchlist** segmented filter pills.
   - Real-time search bar to filter stocks by symbol or company name.
   - Listed equities with directional change arrows (`▲` or `▼`).
   - Tapping any stock navigates to the detailed view.

4. **M4 — Stock Detail Screen (Groww / Upstox / TradingView-Grade Workstation)**:
   - Live price header with positive/negative badge & real-time telemetry.
   - **Chart Types**: Candlestick (wicks & bodies), Hollow Candles, Bar / OHLC, Heikin Ashi, Line, Area.
   - **Timeframe Selector**: `1m`, `5m`, `15m`, `1H`, `1D`, `1W`, `1M`, `3M`, `1Y`, `ALL`.
   - **Indicators**: SMA (20), EMA (20), Bollinger Bands (20, 2), VWAP, Supertrend, Pivot Points (S1, S2, R1, R2, P), Volume Histogram, RSI (14) panel, MACD (12, 26, 9) panel.
   - **Drawing Tools**: Cursor / Pan, Trendline, Horizontal Support/Resistance Line, Fibonacci Retracement (0% to 100%), Clear Drawings.
   - **Crosshair HUD**: Touch or hover over any candle to see Date/Time, Open, High, Low, Close, Volume, and Change %.
   - **Layout Setups**: Default, Intraday Setup (5m + EMA + VWAP + RSI), Swing Setup (1D + Bands + MACD).
   - **Scale Modes**: Linear, Logarithmic, Percentage (%).
   - **Fullscreen Workstation**: Tap the fullscreen button (or AppBar icon) to enter an expansive trading workstation.
   - **Star (★) icon** in the top AppBar to add/remove the stock from your mobile Watchlist.
   - **"View on Web"** button launches the Web App stock workstation.
   - Key Information table (Open, Previous Close, High, Low, Volume, Exchange, Currency).
   - 5-day historical price data table.
   - Related financial news cards.

5. **M5 — Sign In / Registration**:
   - Tabbed login and registration interface.
   - Email format checking & minimum 6-character password validation.
   - Instant feedback and redirect to portfolio.

6. **M6 — Portfolio Screen**:
   - Total Portfolio Valuation card and today's profit/loss metrics.
   - Position cards showing shares, current value, cost basis, and percentage return.
   - **`+` button**: opens the "Add Investment" dialog to enter Symbol, Quantity, and Buy Price.
   - Automatically computes:
     $$\text{Invested} = \text{Qty} \times \text{BuyPrice}$$
     $$\text{Current} = \text{Qty} \times \text{CurrentPrice}$$
     $$\text{P/L} = \text{Current} - \text{Invested}$$
   - Remove button (`✕`) to delete positions.

7. **M7 — Pro Screen**:
   - Value propositions and €9.99/mo plan.
   - Feature list with emerald checkmarks.
   - **Upgrade to Pro** triggers simulated checkout confirmation.

8. **M8 — Settings Screen**:
   - **Location**: Shows current country market and allows changing to any country (satisfying the manual country fallback exam requirement).
   - **Currency**: Switch between `EUR`, `USD`, `GBP`, `INR` to recalculate prices throughout the mobile app.
   - **Backend Server (PHP API)**:
     - Shows current active endpoint (`http://127.0.0.1:8000`, `http://10.0.2.2:8000`, or custom IP).
     - **"Configure"** button: easily change host/IP for real physical phones on Wi-Fi.
     - **"Test"** button: instantly verifies live HTTP 200 connection to `stock.php` and shows real latency and latest quote.
   - **Theme**: Displays active Material 3 design system.
   - **About**: Version & data provider specifications.

---

## 4. How the Mobile App Shows Dynamic Data from the PHP Backend

### Architecture Flow:
```
┌─────────────────────────────────┐
│     PHP Web Backend             │
│     (http://0.0.0.0:8000)       │
│                                 │
│  • api/stock.php                │ ◄─── Central Data Source
│  • api/history.php              │      (config/config.php)
│  • api/search.php               │
│  • api/currency.php             │
│  • api/news.php                 │
└──────────────┬──────────────────┘
               │  HTTP GET (JSON)
               ▼
┌─────────────────────────────────┐
│     Mobile App Client           │
│                                 │
│  1. ApiConstants: Base URL      │
│     - Windows/Web: 127.0.0.1    │
│     - Android Emu: 10.0.2.2     │
│     - Real Phone: 192.168.1.4   │
│     - USB/ADB: 127.0.0.1 (rev)  │
│                                 │
│  2. StockApiService & Models    │
│     - Parses JSON to Dart       │
│     - Graceful cache fallback   │
│                                 │
│  3. UI Screens                  │
│     - Home, Markets, Detail     │
└─────────────────────────────────┘
```

### How to Test Live Dynamic Data Synchronization:
1. Make sure your PHP server is running (`php -S 0.0.0.0:8000 -t web_app`).
2. Open `f:\Stock market app\web_app\config\config.php`.
3. Locate the `SAP` stock price (e.g., change `221.20` to `235.50` or change `companyName`).
4. In the **Mobile App**, open the **Settings** screen and tap **"Test"** under *Backend Server (PHP API)*.
   - You will see: `Connected (HTTP 200) • Live SAP: €235.50`.
5. Navigate to **Markets** or **Stock Detail** in the mobile app: the updated price displays immediately without recompilation!
6. If the PHP backend is ever stopped or offline, the app automatically switches to its built-in offline fallback cache so the user experience is never broken.

---

## 5. Documentation & Exam Presentation Materials

Everything needed for the 5-minute presentation and 15-minute exam Q&A defense is located in the `documentation/` and `figma/` directories:

- **[`documentation/EXAM_DEFENSE_QA.md`](file:///f:/Stock%20market%20app/documentation/EXAM_DEFENSE_QA.md)**:
  Answers to all 11 evaluation questions (Why Flutter, Geolocator mechanism, red/green color rules, PHP proxy architecture, Chart.js, responsive breakpoints, portfolio math, etc.).
- **[`documentation/ARCHITECTURE.md`](file:///f:/Stock%20market%20app/documentation/ARCHITECTURE.md)**:
  Detailed architecture data flow diagram between clients and data services.
- **[`documentation/WIDGET_TREE.md`](file:///f:/Stock%20market%20app/documentation/WIDGET_TREE.md)**:
  Complete Flutter widget trees for each screen (Phase 1 requirement).
- **[`figma/design_tokens.json`](file:///f:/Stock%20market%20app/figma/design_tokens.json)**:
  Design system color codes, typography, spacing, and elevation tokens.
- **[`figma/wireframes_overview.md`](file:///f:/Stock%20market%20app/figma/wireframes_overview.md)**:
  UI layout diagrams and wireframe specifications.
- **[`plan.md`](file:///f:/Stock%20market%20app/plan.md)**:
  Master plan with all completed development steps and testing checklist items marked with `✅`.

---

## 6. Summary of Running Commands

| Application | Command | URL / Target |
| :--- | :--- | :--- |
| **Web App** | `php -S 0.0.0.0:8000 -t web_app` | [http://localhost:8000](http://localhost:8000) or [http://192.168.1.4:8000](http://192.168.1.4:8000) |
| **Mobile App (Windows)** | `cd mobile_app && flutter run -d windows` | Windows Desktop Native Window |
| **Mobile App (Chrome preview)** | `cd mobile_app && flutter run -d chrome` | Web Browser Mobile Emulator |
| **Mobile App (Android)** | `cd mobile_app && flutter run -d <device>` | Connected Android Device / Emulator |
| **Flutter Linter & Health** | `cd mobile_app && flutter analyze` | Zero issues |
