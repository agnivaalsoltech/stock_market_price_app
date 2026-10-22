<?php
require_once __DIR__ . '/../config/config.php';

header('Content-Type: application/json; charset=utf-8');

$symbol = isset($_GET['symbol']) ? strtoupper(trim($_GET['symbol'])) : 'SAP';
$range = isset($_GET['range']) ? strtoupper(trim($_GET['range'])) : '1D';

$stock = getStockData($symbol);
$basePrice = isset($stock['price']) ? (float)$stock['price'] : 221.20;

$historyData = getStockHistoryData($symbol, $range);

echo json_encode([
    'success' => true,
    'symbol' => $symbol,
    'range' => $range,
    'basePrice' => $basePrice,
    'chart' => $historyData['chart'],
    'table' => $historyData['table'],
    'source' => $historyData['source'] ?? 'local',
    'isLive' => $historyData['isLive'] ?? false
], JSON_PRETTY_PRINT);
