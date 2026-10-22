<?php
require_once __DIR__ . '/../config/config.php';

header('Content-Type: application/json; charset=utf-8');

$symbol = isset($_GET['symbol']) ? strtoupper(trim($_GET['symbol'])) : 'SAP';
$range = isset($_GET['range']) ? strtoupper(trim($_GET['range'])) : '1D';

$basePrice = 221.20;
if (isset($STOCKS[$symbol])) {
    $basePrice = $STOCKS[$symbol]['price'];
} else {
    $basePrice = round(100 + (abs(crc32($symbol)) % 300), 2);
}

$history = generateHistoricalPoints($basePrice, $range);

// Also generate a 5-day historical table dataset for detailed breakdown
$today = new DateTime();
$tableData = [];
for ($i = 4; $i >= 0; $i--) {
    $d = (clone $today)->modify("-$i weekdays");
    $dayClose = round($basePrice * (1 + (($i - 2) * 0.008)), 2);
    $tableData[] = [
        'date' => $d->format('d M Y'),
        'open' => round($dayClose * 0.992, 2),
        'high' => round($dayClose * 1.015, 2),
        'low' => round($dayClose * 0.985, 2),
        'close' => $dayClose,
        'volume' => number_format(rand(1800000, 2600000))
    ];
}

echo json_encode([
    'success' => true,
    'symbol' => $symbol,
    'range' => $range,
    'basePrice' => $basePrice,
    'chart' => $history,
    'table' => array_reverse($tableData)
], JSON_PRETTY_PRINT);
