# 📈 MarketPulse — Simple User Guide & Execution Manual

Welcome to **MarketPulse**, a financial market intelligence platform featuring a **Web Application** and a **Flutter Mobile Application** connected to real-time market data.

This guide provides simple, step-by-step instructions to get both apps up and running on your computer.

---

## 📋 Prerequisites in Simple Terms

1. **For the Web Application**:
   - **PHP (version 8.0+)**: No database installation, Apache, or Node.js required. The app uses PHP's built-in development server.
2. **For the Mobile Application**:
   - **Flutter SDK**: Installed on your system.
   - An Android phone, Android emulator, Chrome browser, or Windows desktop target.

---

## 🚀 Part 1: Running the Web Application

The web frontend and REST API run using the built-in PHP development server.

### Step 1: Open Terminal in the Project Folder
Open PowerShell or your command prompt in the main project directory (`Stock market app`):

```powershell
# Verify you are in the project root directory
dir
```

### Step 2: Start the Web Server
Run this single command:

```powershell
php -S 0.0.0.0:8000 -t web_app
```

*You should see:*
`PHP 8.x.x Development Server (http://0.0.0.0:8000) started`

> 💡 **Keep this terminal window open!** The server will continue running here.

### Step 3: Open in Your Browser
Open Chrome, Edge, Firefox, or Brave and visit:
👉 **[http://localhost:8000](http://localhost:8000)** (or **[http://127.0.0.1:8000](http://127.0.0.1:8000)**)

You will see the MarketPulse financial dashboard.

---

## 📡 Part 2: Enabling Live Stock Data (Twelve Data)

MarketPulse has built-in offline catalogs and fallbacks. To enable **live real-time stock quotes and charts**, connect your Twelve Data API key:

### Option A: Directly from the Web Interface (Fastest)
1. In the top navigation bar, click the **📡 API Key / Twelve Data Live** button.
2. Paste your Twelve Data API key in the input box.
3. Click **"Test & Save Key"**. The app will verify connectivity against Twelve Data and enable live streaming instantly.

### Option B: Using the `.env` File
1. Open the `.env` file in the project root.
2. Enter your key:
   ```env
   TWELVE_DATA_API_KEY=your_actual_api_key_here
   ```
3. Save the file. The server will automatically use it on the next request.

> 🛡️ **Rate Limit Protection**: Twelve Data's free tier provides 8 requests per minute. MarketPulse automatically caches live quotes for 60 seconds and historical charts for 5 minutes in `web_app/cache/`. This ensures your quota is never exhausted. If the API is ever unreachable, the app seamlessly serves fallback data without error.

---

## 📱 Part 3: Running the Mobile Application (Flutter)

> ⚠️ **Important:** Keep the PHP server running in your first terminal window!

### Step 1: Open a Second Terminal Window
Open a **new, separate terminal** tab or window.

### Step 2: Navigate to the `mobile_app` Directory
```powershell
cd mobile_app
```

> ⚠️ **Directory Note**: Always run Flutter commands from inside `mobile_app/`. Running from the root directory will produce `Error: No pubspec.yaml file found`.

### Step 3: Launch the Mobile App
```powershell
flutter run
```

Flutter will display a list of available connected devices:
- Choose your physical Android phone, emulator, or Windows desktop.
- To run directly in Google Chrome: `flutter run -d chrome`
- To run directly on Windows Desktop: `flutter run -d windows`

---

## 🌐 Connecting the Mobile App to the Web Server

The mobile app connects to the PHP server to fetch live quotes and candlestick charts.

- **Running on the Same PC (Windows Desktop or Chrome)**:  
  Connects to `http://127.0.0.1:8000`.
- **Running on an Android Emulator**:  
  Connects to `http://10.0.2.2:8000`.
- **Running on a Physical Phone via USB Cable**:  
  Run this one-time command in terminal:
  ```powershell
  adb reverse tcp:8000 tcp:8000
  ```
- **Running on a Physical Phone via Wi-Fi**:  
  Connect your phone to the same Wi-Fi network as your PC. In the mobile app, go to **Settings ⚙️** $\rightarrow$ **Server Connection**, and type your PC's local IP address (e.g., `http://192.168.1.4:8000`).

---

## ✨ Key Features to Explore

| Feature | Description |
| :--- | :--- |
| **🌍 Country & Currency Synchronization** | Switch country between **Germany 🇩🇪**, **USA 🇺🇸**, **UK 🇬🇧**, or **India 🇮🇳**. The active currency automatically updates to **€**, **$**, **£**, or **₹** and recalculates all prices across the platform. |
| **📊 Interactive Financial Charts** | Click any stock ticker (e.g. `SAP`, `AAPL`, `BMW`, `NVDA`) to view candlestick and area charts with timeframes (`1D`, `1W`, `1M`, `3M`, `1Y`, `5Y`). |
| **💼 Portfolio & Holdings** | Track simulated total portfolio value, daily P/L, asset allocation breakdown, and execute simulated trades. |
| **⭐ Custom Watchlist** | Click the star icon (★) next to any stock to track it. Filter by watchlist on the Markets page. |
| **🌙 Dark & Light Themes** | Click the **🌙 / ☀️** toggle in the top navbar to switch between Light Mode and Slate Dark Mode. |

---

## ❓ Troubleshooting & Quick FAQ

#### Q: "PHP is not recognized as an internal or external command"
**Fix**: Ensure PHP is installed and its directory (e.g. `C:\tools\php` or `C:\php`) is added to your Windows System Environment PATH.

#### Q: "Error: No pubspec.yaml file found"
**Fix**: Change directory into `mobile_app` before running Flutter:
```powershell
cd mobile_app
flutter run
```

#### Q: How do I stop the servers?
**Fix**: Press **`Ctrl + C`** in the terminal where the command is running.
