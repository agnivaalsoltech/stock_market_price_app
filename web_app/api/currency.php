<?php
require_once __DIR__ . '/../config/config.php';

header('Content-Type: application/json; charset=utf-8');

$base = isset($_GET['base']) ? strtoupper(trim($_GET['base'])) : 'EUR';

if (!isset($CURRENCY_RATES[$base])) {
    $base = 'EUR';
}

$baseRateInEur = $CURRENCY_RATES[$base];
$convertedRates = [];

foreach ($CURRENCY_RATES as $curr => $rate) {
    // Convert relative to requested base
    $convertedRates[$curr] = round($rate / $baseRateInEur, 4);
}

echo json_encode([
    'success' => true,
    'base' => $base,
    'rates' => $convertedRates,
    'symbols' => [
        'EUR' => '€',
        'USD' => '$',
        'GBP' => '£',
        'INR' => '₹'
    ]
], JSON_PRETTY_PRINT);
