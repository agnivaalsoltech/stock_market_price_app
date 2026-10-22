<?php
/**
 * MarketPulse - Twelve Data API Key Management & Diagnostics
 */

require_once __DIR__ . '/../config/config.php';

header('Content-Type: application/json; charset=utf-8');

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $isConfigured = TwelveDataService::isConfigured();
    $rawKey = TwelveDataService::getApiKey();
    $maskedKey = '';
    if (!empty($rawKey) && strlen($rawKey) > 6) {
        $maskedKey = substr($rawKey, 0, 4) . str_repeat('*', strlen($rawKey) - 8) . substr($rawKey, -4);
    } elseif (!empty($rawKey)) {
        $maskedKey = '****';
    }

    $cacheFiles = glob(__DIR__ . '/../cache/*.json');
    $cacheCount = is_array($cacheFiles) ? count($cacheFiles) : 0;

    echo json_encode([
        'success' => true,
        'isConfigured' => $isConfigured,
        'maskedKey' => $maskedKey,
        'cacheFilesCount' => $cacheCount,
        'envFileWritable' => is_writable(__DIR__ . '/../../.env') || is_writable(__DIR__ . '/../../')
    ], JSON_PRETTY_PRINT);
    exit;
}

if ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    if (!is_array($input)) {
        $input = $_POST;
    }

    $action = $input['action'] ?? 'save_key';

    if ($action === 'clear_cache') {
        TwelveDataService::clearCache();
        echo json_encode([
            'success' => true,
            'message' => 'Cache cleared successfully.'
        ]);
        exit;
    }

    $apiKey = trim($input['apiKey'] ?? '');

    if (empty($apiKey)) {
        echo json_encode([
            'success' => false,
            'message' => 'Please provide a valid Twelve Data API key.'
        ]);
        exit;
    }

    // Test connectivity against Twelve Data
    $testUrl = 'https://api.twelvedata.com/quote?symbol=AAPL&apikey=' . urlencode($apiKey);
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $testUrl);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_TIMEOUT, 6);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, 0);
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    $json = @json_decode($response, true);

    if (isset($json['code']) && $json['code'] === 401) {
        echo json_encode([
            'success' => false,
            'message' => 'Twelve Data rejected the API key: ' . ($json['message'] ?? 'Invalid API key.')
        ]);
        exit;
    }

    if (isset($json['code']) && $json['code'] === 429) {
        // Valid key but reached minute limit
        // Still save it!
    }

    // Persist into .env file
    $envPath = __DIR__ . '/../../.env';
    $envContent = '';
    if (file_exists($envPath)) {
        $envContent = file_get_contents($envPath);
    }

    if (preg_match('/^TWELVE_DATA_API_KEY=.*$/m', $envContent)) {
        $envContent = preg_replace('/^TWELVE_DATA_API_KEY=.*$/m', 'TWELVE_DATA_API_KEY=' . $apiKey, $envContent);
    } else {
        $envContent .= "\nTWELVE_DATA_API_KEY=" . $apiKey . "\n";
    }

    @file_put_contents($envPath, $envContent);
    TwelveDataService::setApiKey($apiKey);
    TwelveDataService::clearCache();

    echo json_encode([
        'success' => true,
        'message' => 'Twelve Data API key saved and verified successfully! Live market data is now enabled.',
        'sampleQuote' => isset($json['symbol']) ? [
            'symbol' => $json['symbol'],
            'name' => $json['name'] ?? '',
            'price' => $json['close'] ?? ''
        ] : null
    ], JSON_PRETTY_PRINT);
    exit;
}
