<?php
require_once __DIR__ . '/../config/config.php';

header('Content-Type: application/json; charset=utf-8');

$symbol = isset($_GET['symbol']) ? strtoupper(trim($_GET['symbol'])) : 'SAP';

$stock = getStockData($symbol);

echo json_encode([
    'success' => true,
    'data' => $stock
], JSON_PRETTY_PRINT);
