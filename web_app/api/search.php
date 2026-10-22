<?php
require_once __DIR__ . '/../config/config.php';

header('Content-Type: application/json; charset=utf-8');

$query = isset($_GET['q']) ? strtolower(trim($_GET['q'])) : '';

$stockResults = [];
$countryResults = [];

if ($query === '') {
    // Return popular/featured stocks and all countries
    foreach ($STOCKS as $s) {
        $stockResults[] = $s;
    }
    foreach ($MARKET_COUNTRIES as $cName => $cData) {
        $countryResults[] = array_merge(['name' => $cName], $cData);
    }
} else {
    // Search stocks
    foreach ($STOCKS as $s) {
        if (strpos(strtolower($s['symbol']), $query) !== false ||
            strpos(strtolower($s['companyName']), $query) !== false ||
            strpos(strtolower($s['country']), $query) !== false ||
            strpos(strtolower($s['sector']), $query) !== false) {
            $stockResults[] = $s;
        }
    }
    
    // Search countries
    foreach ($MARKET_COUNTRIES as $cName => $cData) {
        if (strpos(strtolower($cName), $query) !== false ||
            strpos(strtolower($cData['code']), $query) !== false ||
            strpos(strtolower($cData['mainIndex']), $query) !== false) {
            $countryResults[] = array_merge(['name' => $cName], $cData);
        }
    }
}

echo json_encode([
    'success' => true,
    'query' => $query,
    'total' => count($stockResults) + count($countryResults),
    'stocks' => $stockResults,
    'countries' => $countryResults
], JSON_PRETTY_PRINT);
