<?php
require_once __DIR__ . '/../config/config.php';

header('Content-Type: application/json; charset=utf-8');

$symbol = isset($_GET['symbol']) ? strtoupper(trim($_GET['symbol'])) : 'SAP';

if (isset($STOCKS[$symbol])) {
    $stock = $STOCKS[$symbol];
    $stock['timestamp'] = date('c');
    echo json_encode([
        'success' => true,
        'data' => $stock
    ], JSON_PRETTY_PRINT);
} else {
    // If not found in primary dictionary, return a simulated valid quote based on the symbol
    $simulatedPrice = round(100 + (abs(crc32($symbol)) % 300), 2);
    $simulatedChange = round(((crc32($symbol) % 10) - 4.5), 2);
    $simulatedPercent = round(($simulatedChange / $simulatedPrice) * 100, 2);
    
    echo json_encode([
        'success' => true,
        'data' => [
            'symbol' => $symbol,
            'companyName' => "$symbol Corp",
            'exchange' => 'Global Exchange',
            'country' => 'Global',
            'currency' => 'EUR',
            'price' => $simulatedPrice,
            'open' => round($simulatedPrice * 0.99, 2),
            'high' => round($simulatedPrice * 1.02, 2),
            'low' => round($simulatedPrice * 0.98, 2),
            'previousClose' => round($simulatedPrice - $simulatedChange, 2),
            'change' => $simulatedChange,
            'changePercent' => $simulatedPercent,
            'volume' => 1200000,
            'marketCap' => '€50.0B',
            'peRatio' => 22.5,
            'week52High' => round($simulatedPrice * 1.25, 2),
            'week52Low' => round($simulatedPrice * 0.75, 2),
            'sector' => 'Technology',
            'timestamp' => date('c')
        ]
    ], JSON_PRETTY_PRINT);
}
