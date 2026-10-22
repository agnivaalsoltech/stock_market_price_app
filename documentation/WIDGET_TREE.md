# MarketPulse Flutter Widget Hierarchy Trees

As required by Phase 1 of the assignment, the following widget trees detail the structural architecture of the core screens in the Flutter mobile application.

---

## 1. Overall Application Root Tree
```text
MarketPulseApp (StatelessWidget)
└── MaterialApp
    ├── Theme: AppTheme.lightTheme (Material 3)
    ├── Route Table: AppRoutes
    └── Initial Route: AppRoutes.splash
```

---

## 2. Screen M1 — Splash / Initialization
```text
SplashScreen (StatefulWidget)
└── Scaffold
    └── Container / Center (AppColors.primary)
        └── Column
            ├── Container (Shadow & ClipRRect)
            │   └── Image.asset('assets/images/logo.png')
            ├── Text ('MarketPulse')
            ├── Text ('Your market. Your data.')
            ├── SizedBox
            ├── CircularProgressIndicator (AppColors.secondary)
            └── Text ('Detecting location & market telemetry...')
```

---

## 3. Screen M2 — Home Dashboard
```text
HomeScreen (StatefulWidget)
├── AppBar
│   ├── Title: Logo Image + Text('MarketPulse')
│   └── Actions: [Search IconButton, Profile IconButton]
├── Drawer
│   └── ListView
│       ├── DrawerHeader (MarketPulse branding)
│       └── ListTiles: [Home, Markets, Portfolio, Pro, Settings, Auth]
├── Body: RefreshIndicator
│   └── SingleChildScrollView
│       └── Column
│           ├── LocationHeader (Greeting + Flag + Country + Exchange + Market Status)
│           ├── MarketSummaryCard (Primary Index: DAX / S&P 500, Large Price, Trend)
│           │   └── PriceBadge (Directive color + Arrow)
│           ├── MajorIndicesSection (Title + Horizontal ListView.separated)
│           │   └── MarketCard (Symbol, Mini badge, Price, Change)
│           ├── TopMoversSection (Title + 'See All' Action)
│           │   └── StockCard (Symbol badge, Company, Sector, Price, PriceBadge)
│           └── NewsSection (Title)
│               └── NewsCard (Tag, Source, Title, Summary, External Link)
└── BottomNavigationBar (Home, Markets, Portfolio, Pro)
```

---

## 4. Screen M3 — Markets / Snapshot
```text
MarketsScreen (StatefulWidget)
├── AppBar (Title: 'Markets & Snapshot', Settings Action)
└── Body: RefreshIndicator
    └── SingleChildScrollView
        └── Column
            ├── CountryDropdownRow (Flag + Country Market + 'Open' indicator)
            ├── SearchField (TextField with Prefix Icon & Clear button)
            ├── MajorIndicesRow (Horizontal ListView of MarketCards)
            └── ListedEquitiesList
                └── StockCard (Dynamic green/red badges, Navigation to Detail)
```

---

## 5. Screen M4 — Stock Detail
```text
StockDetailScreen (StatefulWidget)
├── AppBar (Title: Symbol, Add to Portfolio Action, Web Launcher Action)
└── Body: SingleChildScrollView
    └── Column
        ├── StockHeader (Company Name, Exchange, Country, Sector, 'Market Open' badge)
        ├── PriceSection (Large Price Hero, PriceBadge with Absolute + Percent change)
        ├── TimeRangeSelector (1D, 1W, 1M, 3M, 1Y interactive pill switches)
        ├── StockChart (fl_chart LineChart with gradient fill and tooltips)
        ├── WebLauncherButton (InkWell -> 'View detailed charts on Web')
        ├── KeyStatsGrid (Container with 2-column key statistics table)
        ├── HistoricalTable (Horizontal SingleChildScrollView -> DataTable)
        └── RelatedNewsList (NewsCard list with direct article links)
```

---

## 6. Screen M5 — Sign In / Registration
```text
AuthScreen (StatefulWidget)
├── AppBar (Title: 'Account Access')
└── Body: SingleChildScrollView
    └── Column
        ├── Logo Image & Title
        ├── TabBar (Sign In | Register)
        └── TabBarView
            ├── SignInView (Email, Password, Sign In Button, Forgot Password)
            └── RegisterView (Full Name, Email, Password, Confirm Password, Create Account)
```

---

## 7. Screen M6 — Portfolio
```text
PortfolioScreen (StatefulWidget)
├── AppBar (Title: 'My Portfolio', Add Investment Action)
└── Body: SingleChildScrollView
    └── Column
        ├── PortfolioSummaryCard (Total Value, Today's P/L, Invested Cost Basis)
        ├── SectionTitle ('Holdings', Position Count)
        └── HoldingsCardsList
            └── PositionCard (Symbol, Shares, Current Value, Invested, P/L, Return %, Delete Action)
```

---

## 8. Screen M7 — Pro
```text
ProScreen (StatefulWidget)
├── AppBar (Title: 'Go Pro')
└── Body: SingleChildScrollView
    └── Column
        ├── Star Badge Icon
        ├── Title & Subtitle ('MarketPulse Pro')
        ├── PriceCard (€9.99 / month + Feature List with Checkmarks)
        └── UpgradeButton (Triggers Simulated Checkout AlertDialog)
```

---

## 9. Screen M8 — Settings / Preferences
```text
SettingsScreen (StatefulWidget)
├── AppBar (Title: 'Settings & Preferences')
└── Body: ListView
    ├── LocationSection (Current Country, Exchange, 'Change' Button -> Dialog)
    ├── CurrencySection (Active Currency Dropdown: EUR, USD, GBP, INR)
    ├── AppearanceSection (Material 3 Palette info)
    └── AboutSection (App Version, Data Provider info)
```
