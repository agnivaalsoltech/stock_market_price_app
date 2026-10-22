# MarketPulse UI Wireframes & Layout Design

## Design Foundations
- **Color Identity**:
  - Primary Dark Navy: `#111827`
  - Vibrant Accent Blue: `#2563EB`
  - Emerald Green (Positive Gains): `#16A34A`
  - Ruby Red (Negative Drops): `#DC2626`
  - Off-white Surface: `#F8FAFC`
- **Typography**: Inter / Sans-Serif system font with clear typographic hierarchy.
- **Visual Consistency**: Both the mobile application and web application share the exact same brand logo, color rules, and layout logic.

---

## Wireframe Layout Diagrams

### 1. Mobile & Web Home
```
┌──────────────────────────────────────────────────┐
│ [Logo] MarketPulse     Markets  Portfolio  [EUR] │
├──────────────────────────────────────────────────┤
│ HERO: Your Market. Your Data.                    │
│ [ Explore Markets ]    [ Manage Portfolio ]      │
├──────────────────────────────────────────────────┤
│ 📍 Germany Market Overview • Frankfurt Exchange  │
├──────────────────────────────────────────────────┤
│ [ DAX 18,942 ]   [ MDAX 26,521 ]  [ TecDAX 3,412]│
│   ▲ +0.76%            ▼ -0.21%        ▲ +0.44%   │
├────────────────────────┬─────────────────────────┤
│ Trending Equities      │ Market News Snapshot    │
│ • SAP      €221  +3.4% │ • ECB Signals Policy... │
│ • BMW      €81   -2.1% │ • Cloud Demand Rises... │
│ • Siemens  €183  +1.8% │ • Auto Sector Hubs...   │
└────────────────────────┴─────────────────────────┘
```

### 2. Stock Detail View
```
┌──────────────────────────────────────────────────┐
│ ← Back to Markets     SAP SE (XETRA)             │
│ €221.20   ▲ +7.31 (+3.42%)    ● Market Open      │
├──────────────────────────────────────────────────┤
│ [ 1D ]  [ 1W / 1M ]  [ 3M ]  [ 1Y ]              │
│ ┌──────────────────────────────────────────────┐ │
│ │                  /\                          │ │
│ │            _/\__/  \                         │ │
│ │  _________/         \                        │ │
│ └──────────────────────────────────────────────┘ │
├────────────────────────┬─────────────────────────┤
│ Key Statistics         │ Historical Price Table  │
│ Open:        €217.50   │ 22 Sep:  €221.20        │
│ Prev Close:  €213.89   │ 21 Sep:  €218.40        │
│ Day High:    €222.40   │ 20 Sep:  €219.90        │
│ Day Low:     €216.80   │ 19 Sep:  €220.70        │
└────────────────────────┴─────────────────────────┘
```

### 3. Portfolio Management
```
┌──────────────────────────────────────────────────┐
│ Portfolio Value: €24,820.50                      │
│ Today's P/L:     +€1,420.50 (+6.07%)             │
├────────────────────────┬─────────────────────────┤
│ Asset Allocation       │ Holdings Positions      │
│ (Chart.js Doughnut)    │ • SAP: 10 sh @ €195     │
│ [ SAP 40% | BMW 25% ]  │ • BMW: 15 sh @ €86      │
│                        │ [ + Add Investment ]    │
└────────────────────────┴─────────────────────────┘
```
