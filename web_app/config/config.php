<?php
/**
 * MarketPulse Central Configuration & Data Provider
 * Supports multiple country markets, stock quotes, historical time series, news, and exchange rates.
 */

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Twelve Data Service & Live Data Provider
require_once __DIR__ . '/../services/TwelveDataService.php';

// Default Twelve Data API Key (can be set here, in .env, or via environment variable)
if (!defined('TWELVE_DATA_API_KEY')) {
    define('TWELVE_DATA_API_KEY', getenv('TWELVE_DATA_API_KEY') ?: '');
}
TwelveDataService::init();

$MARKET_COUNTRIES = [
    'Germany' => [
        'code' => 'DE',
        'currency' => 'EUR',
        'exchange' => 'XETRA (Frankfurt)',
        'flag' => '🇩🇪',
        'status' => 'Open',
        'mainIndex' => 'DAX',
        'indices' => [
            ['symbol' => 'DAX', 'name' => 'DAX 40', 'price' => 18942.31, 'change' => 143.28, 'changePercent' => 0.76],
            ['symbol' => 'MDAX', 'name' => 'MDAX', 'price' => 26521.10, 'change' => -55.80, 'changePercent' => -0.21],
            ['symbol' => 'TecDAX', 'name' => 'TecDAX', 'price' => 3412.45, 'change' => 14.90, 'changePercent' => 0.44]
        ]
    ],
    'USA' => [
        'code' => 'US',
        'currency' => 'USD',
        'exchange' => 'NYSE / NASDAQ',
        'flag' => '🇺🇸',
        'status' => 'Open',
        'mainIndex' => 'S&P 500',
        'indices' => [
            ['symbol' => 'S&P 500', 'name' => 'S&P 500', 'price' => 5612.40, 'change' => 38.50, 'changePercent' => 0.69],
            ['symbol' => 'NASDAQ', 'name' => 'NASDAQ Composite', 'price' => 17683.98, 'change' => 124.30, 'changePercent' => 0.71],
            ['symbol' => 'DJIA', 'name' => 'Dow Jones Industrial', 'price' => 41535.07, 'change' => -45.10, 'changePercent' => -0.11]
        ]
    ],
    'United Kingdom' => [
        'code' => 'GB',
        'currency' => 'GBP',
        'exchange' => 'LSE (London)',
        'flag' => '🇬🇧',
        'status' => 'Open',
        'mainIndex' => 'FTSE 100',
        'indices' => [
            ['symbol' => 'FTSE 100', 'name' => 'FTSE 100 Index', 'price' => 8273.43, 'change' => 21.30, 'changePercent' => 0.26],
            ['symbol' => 'FTSE 250', 'name' => 'FTSE 250', 'price' => 20780.12, 'change' => -32.40, 'changePercent' => -0.16]
        ]
    ],
    'India' => [
        'code' => 'IN',
        'currency' => 'INR',
        'exchange' => 'NSE / BSE (Mumbai)',
        'flag' => '🇮🇳',
        'status' => 'Open',
        'mainIndex' => 'NIFTY 50',
        'indices' => [
            ['symbol' => 'NIFTY 50', 'name' => 'Nifty 50 Index', 'price' => 25377.80, 'change' => 89.20, 'changePercent' => 0.35],
            ['symbol' => 'SENSEX', 'name' => 'BSE SENSEX', 'price' => 82890.94, 'change' => 236.80, 'changePercent' => 0.29]
        ]
    ]
];

$STOCKS = [
    // Germany
    'SAP' => [
        'symbol' => 'SAP',
        'companyName' => 'SAP SE',
        'exchange' => 'XETRA',
        'country' => 'Germany',
        'currency' => 'EUR',
        'price' => 221.20,
        'open' => 217.50,
        'high' => 222.40,
        'low' => 216.80,
        'previousClose' => 213.89,
        'change' => 7.31,
        'changePercent' => 3.42,
        'volume' => 2145000,
        'marketCap' => '€262.4B',
        'peRatio' => 38.4,
        'week52High' => 224.50,
        'week52Low' => 119.80,
        'sector' => 'Enterprise Software'
    ],
    'BMW' => [
        'symbol' => 'BMW',
        'companyName' => 'Bayerische Motoren Werke AG',
        'exchange' => 'XETRA',
        'country' => 'Germany',
        'currency' => 'EUR',
        'price' => 81.30,
        'open' => 83.20,
        'high' => 83.60,
        'low' => 80.90,
        'previousClose' => 83.09,
        'change' => -1.79,
        'changePercent' => -2.15,
        'volume' => 1420000,
        'marketCap' => '€51.8B',
        'peRatio' => 5.6,
        'week52High' => 115.35,
        'week52Low' => 77.20,
        'sector' => 'Automotive'
    ],
    'SIE' => [
        'symbol' => 'SIE',
        'companyName' => 'Siemens AG',
        'exchange' => 'XETRA',
        'country' => 'Germany',
        'currency' => 'EUR',
        'price' => 183.40,
        'open' => 180.50,
        'high' => 184.20,
        'low' => 180.10,
        'previousClose' => 180.02,
        'change' => 3.38,
        'changePercent' => 1.88,
        'volume' => 1180000,
        'marketCap' => '€146.2B',
        'peRatio' => 17.2,
        'week52High' => 188.88,
        'week52Low' => 120.40,
        'sector' => 'Industrial Technology'
    ],
    'VOW3' => [
        'symbol' => 'VOW3',
        'companyName' => 'Volkswagen AG',
        'exchange' => 'XETRA',
        'country' => 'Germany',
        'currency' => 'EUR',
        'price' => 91.10,
        'open' => 91.80,
        'high' => 92.40,
        'low' => 90.60,
        'previousClose' => 91.50,
        'change' => -0.40,
        'changePercent' => -0.44,
        'volume' => 890000,
        'marketCap' => '€45.6B',
        'peRatio' => 3.8,
        'week52High' => 128.60,
        'week52Low' => 88.50,
        'sector' => 'Automotive'
    ],
    'ALV' => [
        'symbol' => 'ALV',
        'companyName' => 'Allianz SE',
        'exchange' => 'XETRA',
        'country' => 'Germany',
        'currency' => 'EUR',
        'price' => 284.50,
        'open' => 282.00,
        'high' => 285.80,
        'low' => 281.30,
        'previousClose' => 281.40,
        'change' => 3.10,
        'changePercent' => 1.10,
        'volume' => 740000,
        'marketCap' => '€112.5B',
        'peRatio' => 11.4,
        'week52High' => 289.00,
        'week52Low' => 212.10,
        'sector' => 'Financial Services'
    ],

    // USA
    'AAPL' => [
        'symbol' => 'AAPL',
        'companyName' => 'Apple Inc.',
        'exchange' => 'NASDAQ',
        'country' => 'USA',
        'currency' => 'USD',
        'price' => 228.40,
        'open' => 225.80,
        'high' => 229.30,
        'low' => 225.10,
        'previousClose' => 224.23,
        'change' => 4.17,
        'changePercent' => 1.86,
        'volume' => 48200000,
        'marketCap' => '$3.48T',
        'peRatio' => 34.2,
        'week52High' => 237.23,
        'week52Low' => 164.08,
        'sector' => 'Consumer Electronics'
    ],
    'MSFT' => [
        'symbol' => 'MSFT',
        'companyName' => 'Microsoft Corporation',
        'exchange' => 'NASDAQ',
        'country' => 'USA',
        'currency' => 'USD',
        'price' => 432.10,
        'open' => 428.00,
        'high' => 434.50,
        'low' => 427.20,
        'previousClose' => 426.55,
        'change' => 5.55,
        'changePercent' => 1.30,
        'volume' => 19500000,
        'marketCap' => '$3.21T',
        'peRatio' => 36.1,
        'week52High' => 468.35,
        'week52Low' => 309.45,
        'sector' => 'Cloud & Software'
    ],
    'NVDA' => [
        'symbol' => 'NVDA',
        'companyName' => 'NVIDIA Corporation',
        'exchange' => 'NASDAQ',
        'country' => 'USA',
        'currency' => 'USD',
        'price' => 124.60,
        'open' => 120.50,
        'high' => 126.10,
        'low' => 119.80,
        'previousClose' => 119.12,
        'change' => 5.48,
        'changePercent' => 4.60,
        'volume' => 64300000,
        'marketCap' => '$3.06T',
        'peRatio' => 48.5,
        'week52High' => 140.76,
        'week52Low' => 39.23,
        'sector' => 'Semiconductors'
    ],
    'TSLA' => [
        'symbol' => 'TSLA',
        'companyName' => 'Tesla, Inc.',
        'exchange' => 'NASDAQ',
        'country' => 'USA',
        'currency' => 'USD',
        'price' => 242.30,
        'open' => 249.00,
        'high' => 250.20,
        'low' => 240.10,
        'previousClose' => 248.00,
        'change' => -5.70,
        'changePercent' => -2.30,
        'volume' => 58200000,
        'marketCap' => '$774.2B',
        'peRatio' => 61.2,
        'week52High' => 271.00,
        'week52Low' => 138.80,
        'sector' => 'Electric Vehicles'
    ],

    // UK
    'SHEL' => [
        'symbol' => 'SHEL',
        'companyName' => 'Shell plc',
        'exchange' => 'LSE',
        'country' => 'United Kingdom',
        'currency' => 'GBP',
        'price' => 26.45,
        'open' => 26.20,
        'high' => 26.65,
        'low' => 26.10,
        'previousClose' => 26.15,
        'change' => 0.30,
        'changePercent' => 1.15,
        'volume' => 9200000,
        'marketCap' => '£168.4B',
        'peRatio' => 11.2,
        'week52High' => 29.80,
        'week52Low' => 23.40,
        'sector' => 'Energy'
    ],
    'AZN' => [
        'symbol' => 'AZN',
        'companyName' => 'AstraZeneca PLC',
        'exchange' => 'LSE',
        'country' => 'United Kingdom',
        'currency' => 'GBP',
        'price' => 124.80,
        'open' => 126.50,
        'high' => 126.80,
        'low' => 123.90,
        'previousClose' => 126.32,
        'change' => -1.52,
        'changePercent' => -1.20,
        'volume' => 3100000,
        'marketCap' => '£193.1B',
        'peRatio' => 34.0,
        'week52High' => 134.10,
        'week52Low' => 97.60,
        'sector' => 'Pharmaceuticals'
    ],

    // India
    'RELIANCE' => [
        'symbol' => 'RELIANCE',
        'companyName' => 'Reliance Industries Ltd',
        'exchange' => 'NSE',
        'country' => 'India',
        'currency' => 'INR',
        'price' => 2980.50,
        'open' => 2940.00,
        'high' => 2995.00,
        'low' => 2935.00,
        'previousClose' => 2936.50,
        'change' => 44.00,
        'changePercent' => 1.50,
        'volume' => 4500000,
        'marketCap' => '₹20.1T',
        'peRatio' => 28.2,
        'week52High' => 3217.90,
        'week52Low' => 2221.05,
        'sector' => 'Conglomerate'
    ],
    'TCS' => [
        'symbol' => 'TCS',
        'companyName' => 'Tata Consultancy Services',
        'exchange' => 'NSE',
        'country' => 'India',
        'currency' => 'INR',
        'price' => 4480.00,
        'open' => 4450.00,
        'high' => 4510.00,
        'low' => 4435.00,
        'previousClose' => 4440.00,
        'change' => 40.00,
        'changePercent' => 0.90,
        'volume' => 1800000,
        'marketCap' => '₹16.2T',
        'peRatio' => 32.5,
        'week52High' => 4585.00,
        'week52Low' => 3313.00,
        'sector' => 'IT Services'
    ]
];

$CURRENCY_RATES = [
    'EUR' => 1.0,
    'USD' => 1.09,
    'GBP' => 0.85,
    'INR' => 91.20
];

$NEWS_FEED = [
    [
        'id' => 1,
        'title' => 'European Central Bank Signals Steady Course on Key Interest Rates',
        'source' => 'Financial Times',
        'time' => '15m ago',
        'publishedAt' => '2026-09-22T10:30:00',
        'symbol' => 'SAP',
        'country' => 'Germany',
        'url' => 'https://www.ft.com',
        'summary' => 'European tech and industrial leaders reacted positively to today\'s central bank policy briefing in Frankfurt.'
    ],
    [
        'id' => 2,
        'title' => 'Enterprise Cloud Demand Boosts SAP and Software Sector Margins',
        'source' => 'Reuters',
        'time' => '32m ago',
        'publishedAt' => '2026-09-22T10:10:00',
        'symbol' => 'SAP',
        'country' => 'Germany',
        'url' => 'https://www.reuters.com',
        'summary' => 'Analysts raised price targets following accelerated adoption of AI-infused ERP solutions across multinational clients.'
    ],
    [
        'id' => 3,
        'title' => 'Automotive Sector Faces Supply Chain Adjustments Across European Hubs',
        'source' => 'Bloomberg',
        'time' => '1h ago',
        'publishedAt' => '2026-09-22T09:40:00',
        'symbol' => 'BMW',
        'country' => 'Germany',
        'url' => 'https://www.bloomberg.com',
        'summary' => 'German auto manufacturers adjust battery material sourcing guidelines to reinforce domestic EV competitiveness.'
    ],
    [
        'id' => 4,
        'title' => 'Global Semiconductor Momentum Drives Tech Indices to Multi-Month Highs',
        'source' => 'Wall Street Journal',
        'time' => '2h ago',
        'publishedAt' => '2026-09-22T08:50:00',
        'symbol' => 'NVDA',
        'country' => 'USA',
        'url' => 'https://www.wsj.com',
        'summary' => 'Chip designers and equipment suppliers register strong institutional capital inflows following server hardware rollouts.'
    ],
    [
        'id' => 5,
        'title' => 'London and Mumbai Markets Gain Traction on Infrastructure Investment Plans',
        'source' => 'CNBC',
        'time' => '3h ago',
        'publishedAt' => '2026-09-22T07:30:00',
        'symbol' => 'RELIANCE',
        'country' => 'India',
        'url' => 'https://www.cnbc.com',
        'summary' => 'Cross-border green energy joint ventures fuel trading volumes on prominent Commonwealth exchanges.'
    ]
];

/**
 * Generate historical chart points for 1D, 1M, 3M, 1Y based on baseline price
 */
function generateHistoricalPoints($basePrice, $range = '1D') {
    $points = [];
    $today = new DateTime();
    
    switch (strtoupper($range)) {
        case '1M_INTRA':
        case '1MIN':
        case '1M':
            // If requested as 1-minute intra
            if ($range === '1m') {
                $price = $basePrice * 0.997;
                $prev = $price;
                for ($i = 25; $i >= 0; $i--) {
                    $t = (clone $today)->modify("-$i minutes");
                    $fluctuation = (sin($i * 0.8) * 0.002) + ((rand(-3, 3)) * 0.001);
                    $price = ($i === 0) ? $basePrice : round($price * (1 + $fluctuation), 2);
                    $vol = rand(8000, 42000);
                    $points[] = [
                        'date' => $t->format('H:i'),
                        'open' => $prev,
                        'high' => round(max($prev, $price) * 1.0015, 2),
                        'low' => round(min($prev, $price) * 0.9985, 2),
                        'close' => $price,
                        'volume' => $vol
                    ];
                    $prev = $price;
                }
                break;
            }
            // Standard 1M (1 Month)
            $prev = $basePrice * 0.94;
            for ($i = 20; $i >= 0; $i--) {
                $d = (clone $today)->modify("-$i days");
                $fluctuation = (sin($i * 0.4) * 0.02) + ((rand(-4, 6)) * 0.005);
                $price = ($i === 0) ? $basePrice : round($basePrice * (0.94 + (20 - $i) * 0.003 + $fluctuation), 2);
                $vol = rand(850000, 2400000);
                $points[] = [
                    'date' => $d->format('d M'),
                    'open' => $prev,
                    'high' => round(max($prev, $price) * 1.012, 2),
                    'low' => round(min($prev, $price) * 0.988, 2),
                    'close' => $price,
                    'volume' => $vol
                ];
                $prev = $price;
            }
            break;

        case '5M':
            $price = $basePrice * 0.994;
            $prev = $price;
            for ($i = 20; $i >= 0; $i--) {
                $t = (clone $today)->modify("-" . ($i * 5) . " minutes");
                $fluctuation = (sin($i * 0.6) * 0.003) + ((rand(-3, 4)) * 0.0015);
                $price = ($i === 0) ? $basePrice : round($price * (1 + $fluctuation), 2);
                $vol = rand(15000, 65000);
                $points[] = [
                    'date' => $t->format('H:i'),
                    'open' => $prev,
                    'high' => round(max($prev, $price) * 1.002, 2),
                    'low' => round(min($prev, $price) * 0.998, 2),
                    'close' => $price,
                    'volume' => $vol
                ];
                $prev = $price;
            }
            break;

        case '15M':
            $price = $basePrice * 0.99;
            $prev = $price;
            for ($i = 16; $i >= 0; $i--) {
                $t = (clone $today)->modify("-" . ($i * 15) . " minutes");
                $fluctuation = (sin($i * 0.5) * 0.004) + ((rand(-4, 5)) * 0.002);
                $price = ($i === 0) ? $basePrice : round($price * (1 + $fluctuation), 2);
                $vol = rand(30000, 110000);
                $points[] = [
                    'date' => $t->format('H:i'),
                    'open' => $prev,
                    'high' => round(max($prev, $price) * 1.003, 2),
                    'low' => round(min($prev, $price) * 0.997, 2),
                    'close' => $price,
                    'volume' => $vol
                ];
                $prev = $price;
            }
            break;

        case '1H':
            $price = $basePrice * 0.985;
            $prev = $price;
            for ($i = 12; $i >= 0; $i--) {
                $t = (clone $today)->modify("-$i hours");
                $fluctuation = (sin($i * 0.5) * 0.006) + ((rand(-4, 6)) * 0.003);
                $price = ($i === 0) ? $basePrice : round($price * (1 + $fluctuation), 2);
                $vol = rand(60000, 220000);
                $points[] = [
                    'date' => $t->format('H:i'),
                    'open' => $prev,
                    'high' => round(max($prev, $price) * 1.005, 2),
                    'low' => round(min($prev, $price) * 0.995, 2),
                    'close' => $price,
                    'volume' => $vol
                ];
                $prev = $price;
            }
            break;

        case '1D':
            // Hourly intra-day points
            $hours = ['09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00', '17:30'];
            $price = $basePrice * 0.985;
            $prev = $price;
            foreach ($hours as $time) {
                $fluctuation = (sin(count($points) * 0.8) * 0.008) + ((rand(-3, 6)) * 0.003);
                $price = round($price * (1 + $fluctuation), 2);
                $vol = rand(45000, 195000);
                $points[] = [
                    'date' => $time,
                    'open' => $prev,
                    'high' => round(max($prev, $price) * 1.004, 2),
                    'low' => round(min($prev, $price) * 0.996, 2),
                    'close' => $price,
                    'volume' => $vol
                ];
                $prev = $price;
            }
            $points[count($points) - 1]['close'] = $basePrice;
            $points[count($points) - 1]['high'] = max($points[count($points) - 1]['high'], $basePrice);
            break;
            
        case '1W':
            $prev = $basePrice * 0.97;
            for ($i = 6; $i >= 0; $i--) {
                $d = (clone $today)->modify("-$i days");
                $fluctuation = (sin($i * 0.9) * 0.015) + ((rand(-5, 8)) * 0.004);
                $price = ($i === 0) ? $basePrice : round($basePrice * (0.97 + (6 - $i) * 0.005 + $fluctuation), 2);
                $vol = rand(650000, 1850000);
                $points[] = [
                    'date' => $d->format('d M'),
                    'open' => $prev,
                    'high' => round(max($prev, $price) * 1.008, 2),
                    'low' => round(min($prev, $price) * 0.992, 2),
                    'close' => $price,
                    'volume' => $vol
                ];
                $prev = $price;
            }
            break;

        case '3M':
            $prev = $basePrice * 0.90;
            for ($i = 12; $i >= 0; $i--) {
                $d = (clone $today)->modify("-$i weeks");
                $fluctuation = (cos($i * 0.5) * 0.03) + ((rand(-5, 7)) * 0.006);
                $price = ($i === 0) ? $basePrice : round($basePrice * (0.90 + (12 - $i) * 0.008 + $fluctuation), 2);
                $vol = rand(950000, 2800000);
                $points[] = [
                    'date' => $d->format('d M'),
                    'open' => $prev,
                    'high' => round(max($prev, $price) * 1.016, 2),
                    'low' => round(min($prev, $price) * 0.984, 2),
                    'close' => $price,
                    'volume' => $vol
                ];
                $prev = $price;
            }
            break;

        case 'ALL':
        case '5Y':
            $prev = $basePrice * 0.55;
            for ($i = 24; $i >= 0; $i--) {
                $d = (clone $today)->modify("-" . ($i * 2.5) . " months");
                $fluctuation = (sin($i * 0.7) * 0.08) + ((rand(-8, 12)) * 0.01);
                $price = ($i === 0) ? $basePrice : round($basePrice * (0.55 + (24 - $i) * 0.018 + $fluctuation), 2);
                $vol = rand(1500000, 4500000);
                $points[] = [
                    'date' => $d->format('M Y'),
                    'open' => $prev,
                    'high' => round(max($prev, $price) * 1.035, 2),
                    'low' => round(min($prev, $price) * 0.965, 2),
                    'close' => $price,
                    'volume' => $vol
                ];
                $prev = $price;
            }
            break;

        case '1Y':
        default:
            $prev = $basePrice * 0.82;
            for ($i = 12; $i >= 0; $i--) {
                $d = (clone $today)->modify("-$i months");
                $fluctuation = (sin($i * 0.6) * 0.05) + ((rand(-6, 8)) * 0.008);
                $price = ($i === 0) ? $basePrice : round($basePrice * (0.82 + (12 - $i) * 0.015 + $fluctuation), 2);
                $vol = rand(1200000, 3200000);
                $points[] = [
                    'date' => $d->format('M Y'),
                    'open' => $prev,
                    'high' => round(max($prev, $price) * 1.025, 2),
                    'low' => round(min($prev, $price) * 0.975, 2),
                    'close' => $price,
                    'volume' => $vol
                ];
                $prev = $price;
            }
            break;
    }
    
    return $points;
}

/**
 * Unified Stock Data Provider
 * Fetches real-time live data via Twelve Data if configured, or returns local fallback.
 */
function getStockData(string $symbol): array {
    global $STOCKS;
    return TwelveDataService::getQuote($symbol, $STOCKS);
}

/**
 * Unified Stock History Data Provider
 * Fetches real-time candles via Twelve Data if configured, or generates smooth points.
 */
function getStockHistoryData(string $symbol, string $range = '1D'): array {
    $stock = getStockData($symbol);
    $basePrice = isset($stock['price']) ? (float)$stock['price'] : 200.0;
    return TwelveDataService::getTimeSeries($symbol, $range, $basePrice, 'generateHistoricalPoints');
}
