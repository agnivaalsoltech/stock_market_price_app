<?php
require_once __DIR__ . '/../config/config.php';

header('Content-Type: application/json; charset=utf-8');

$symbol = isset($_GET['symbol']) ? strtoupper(trim($_GET['symbol'])) : null;
$country = isset($_GET['country']) ? trim($_GET['country']) : null;

$filtered = [];

foreach ($NEWS_FEED as $item) {
    $match = true;
    if ($symbol && strtoupper($item['symbol']) !== $symbol) {
        $match = false;
    }
    if ($country && strcasecmp($item['country'], $country) !== 0) {
        $match = false;
    }
    
    if ($match) {
        $filtered[] = $item;
    }
}

// Fallback to all news if specific filter yielded none
if (empty($filtered)) {
    $filtered = $NEWS_FEED;
}

echo json_encode([
    'success' => true,
    'count' => count($filtered),
    'news' => $filtered
], JSON_PRETTY_PRINT);
