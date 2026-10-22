<?php
/**
 * MarketPulse - Twelve Data Live API Service
 * Handles live quotes, real-time time series charts, symbol search,
 * intelligent caching (to protect rate limits), and seamless local fallback.
 */

class TwelveDataService {
    private static ?string $apiKey = null;
    private static string $cacheDir = __DIR__ . '/../cache';
    private static int $quoteCacheTtl = 60;       // 60 seconds TTL for live quotes
    private static int $chartCacheTtl = 300;      // 5 minutes TTL for historical charts

    /**
     * Initializes environment variables and active API key.
     */
    public static function init(): void {
        if (self::$apiKey !== null) {
            return;
        }

        // 1. Try loading from .env files (project root or web_app/)
        self::loadEnvFile(__DIR__ . '/../../.env');
        self::loadEnvFile(__DIR__ . '/../.env');

        // 2. Read from environment or constant
        $key = getenv('TWELVE_DATA_API_KEY');
        if (!$key && isset($_ENV['TWELVE_DATA_API_KEY'])) {
            $key = $_ENV['TWELVE_DATA_API_KEY'];
        }
        if (!$key && defined('TWELVE_DATA_API_KEY')) {
            $key = constant('TWELVE_DATA_API_KEY');
        }

        self::$apiKey = is_string($key) ? trim($key) : '';

        // Ensure cache directory exists
        if (!is_dir(self::$cacheDir)) {
            @mkdir(self::$cacheDir, 0777, true);
        }
    }

    /**
     * Check if a valid API key is currently configured.
     */
    public static function isConfigured(): bool {
        self::init();
        return !empty(self::$apiKey) && self::$apiKey !== 'YOUR_TWELVE_DATA_API_KEY_HERE';
    }

    /**
     * Returns the currently configured API key (or empty string).
     */
    public static function getApiKey(): string {
        self::init();
        return self::$apiKey ?? '';
    }

    /**
     * Manually override or set the API key for the current request.
     */
    public static function setApiKey(string $key): void {
        self::$apiKey = trim($key);
    }

    /**
     * Fetches real-time stock quote from Twelve Data, with caching and fallback.
     */
    public static function getQuote(string $symbol, array $allFallbackStocks = []): array {
        self::init();
        $symbol = strtoupper(trim($symbol));
        if ($symbol === '') {
            $symbol = 'SAP';
        }

        // Identify local baseline fallback first
        $localFallback = $allFallbackStocks[$symbol] ?? null;
        if (!$localFallback) {
            $simPrice = round(100 + (abs(crc32($symbol)) % 300), 2);
            $simChange = round(((crc32($symbol) % 10) - 4.5), 2);
            $localFallback = [
                'symbol' => $symbol,
                'companyName' => "$symbol Corp",
                'exchange' => 'Global Exchange',
                'country' => 'Global',
                'currency' => 'USD',
                'price' => $simPrice,
                'open' => round($simPrice * 0.99, 2),
                'high' => round($simPrice * 1.02, 2),
                'low' => round($simPrice * 0.98, 2),
                'previousClose' => round($simPrice - $simChange, 2),
                'change' => $simChange,
                'changePercent' => round(($simChange / $simPrice) * 100, 2),
                'volume' => 1200000,
                'marketCap' => '€50.0B',
                'peRatio' => 22.5,
                'week52High' => round($simPrice * 1.25, 2),
                'week52Low' => round($simPrice * 0.75, 2),
                'sector' => 'Technology',
                'timestamp' => date('c'),
                'source' => 'local_simulated',
                'isLive' => false
            ];
        } else {
            $localFallback['source'] = 'local_catalog';
            $localFallback['isLive'] = false;
            $localFallback['timestamp'] = date('c');
        }

        // If not configured, immediately return local fallback without network delay
        if (!self::isConfigured()) {
            return $localFallback;
        }

        // Check local disk cache (prevents exhausting Twelve Data free 8 req/min limit)
        $cleanSym = preg_replace('/[^A-Za-z0-9_-]/', '', $symbol);
        $cacheFile = self::$cacheDir . "/quote_{$cleanSym}.json";
        if (file_exists($cacheFile) && (time() - filemtime($cacheFile) < self::$quoteCacheTtl)) {
            $cached = @json_decode(file_get_contents($cacheFile), true);
            if (is_array($cached) && !empty($cached['symbol'])) {
                $cached['fromCache'] = true;
                return $cached;
            }
        }

        // Outbound request to Twelve Data Quote endpoint
        $url = 'https://api.twelvedata.com/quote?' . http_build_query([
            'symbol' => $symbol,
            'apikey' => self::$apiKey
        ]);

        $res = self::makeHttpRequest($url);
        if (!$res || empty($res['body'])) {
            return $localFallback;
        }

        $json = @json_decode($res['body'], true);
        if (!is_array($json) || isset($json['code']) || (isset($json['status']) && $json['status'] === 'error') || empty($json['symbol'])) {
            // Error from Twelve Data (e.g. rate limit 429 or unknown symbol) -> graceful fallback
            return $localFallback;
        }

        // Normalize live response into application schema
        $price = isset($json['close']) ? (float)$json['close'] : (float)($json['price'] ?? $localFallback['price']);
        $open = isset($json['open']) && $json['open'] !== null ? (float)$json['open'] : $price;
        $high = isset($json['high']) && $json['high'] !== null ? (float)$json['high'] : $price;
        $low = isset($json['low']) && $json['low'] !== null ? (float)$json['low'] : $price;
        $prevClose = isset($json['previous_close']) && $json['previous_close'] !== null ? (float)$json['previous_close'] : $price;
        $change = isset($json['change']) && $json['change'] !== null ? (float)$json['change'] : round($price - $prevClose, 2);
        $changePct = isset($json['percent_change']) && $json['percent_change'] !== null ? (float)$json['percent_change'] : ($prevClose > 0 ? round(($change / $prevClose) * 100, 2) : 0.0);
        $volume = isset($json['volume']) ? (int)$json['volume'] : (int)($localFallback['volume'] ?? 1000000);

        $week52Low = isset($json['fifty_two_week']['low']) ? (float)$json['fifty_two_week']['low'] : (float)($localFallback['week52Low'] ?? ($price * 0.8));
        $week52High = isset($json['fifty_two_week']['high']) ? (float)$json['fifty_two_week']['high'] : (float)($localFallback['week52High'] ?? ($price * 1.2));

        $normalized = [
            'symbol' => $json['symbol'],
            'companyName' => !empty($json['name']) ? $json['name'] : $localFallback['companyName'],
            'exchange' => !empty($json['exchange']) ? $json['exchange'] : $localFallback['exchange'],
            'country' => $localFallback['country'] ?? 'USA',
            'currency' => !empty($json['currency']) ? $json['currency'] : ($localFallback['currency'] ?? 'USD'),
            'price' => $price,
            'open' => $open,
            'high' => $high,
            'low' => $low,
            'previousClose' => $prevClose,
            'change' => $change,
            'changePercent' => $changePct,
            'volume' => $volume,
            'marketCap' => $localFallback['marketCap'] ?? 'N/A',
            'peRatio' => $localFallback['peRatio'] ?? 0.0,
            'week52High' => $week52High,
            'week52Low' => $week52Low,
            'sector' => $localFallback['sector'] ?? 'General Equities',
            'timestamp' => $json['datetime'] ?? date('c'),
            'source' => 'twelve_data_live',
            'isLive' => true
        ];

        // Store into cache
        @file_put_contents($cacheFile, json_encode($normalized, JSON_PRETTY_PRINT));

        return $normalized;
    }

    /**
     * Fetches real-time time series chart data from Twelve Data with fallback.
     */
    public static function getTimeSeries(string $symbol, string $range, float $basePrice, callable $fallbackGenerator): array {
        self::init();
        $symbol = strtoupper(trim($symbol));
        $range = strtoupper(trim($range));

        if (!self::isConfigured()) {
            return [
                'chart' => $fallbackGenerator($basePrice, $range),
                'table' => self::generateFallbackTable($basePrice),
                'source' => 'local_fallback',
                'isLive' => false
            ];
        }

        // Map range to Twelve Data interval and output size
        $paramMap = [
            '1D'  => ['interval' => '5min',  'outputsize' => 45],
            '1W'  => ['interval' => '1h',    'outputsize' => 35],
            '1M'  => ['interval' => '1day',  'outputsize' => 30],
            '3M'  => ['interval' => '1day',  'outputsize' => 65],
            '1Y'  => ['interval' => '1week', 'outputsize' => 52],
            '5Y'  => ['interval' => '1month','outputsize' => 60],
            'ALL' => ['interval' => '1month','outputsize' => 72],
        ];

        $cfg = $paramMap[$range] ?? $paramMap['1D'];
        $cleanSym = preg_replace('/[^A-Za-z0-9_-]/', '', $symbol);
        $cacheFile = self::$cacheDir . "/chart_{$cleanSym}_{$range}.json";

        // Check cache
        if (file_exists($cacheFile) && (time() - filemtime($cacheFile) < self::$chartCacheTtl)) {
            $cached = @json_decode(file_get_contents($cacheFile), true);
            if (is_array($cached) && !empty($cached['chart'])) {
                $cached['fromCache'] = true;
                return $cached;
            }
        }

        $url = 'https://api.twelvedata.com/time_series?' . http_build_query([
            'symbol' => $symbol,
            'interval' => $cfg['interval'],
            'outputsize' => $cfg['outputsize'],
            'apikey' => self::$apiKey
        ]);

        $res = self::makeHttpRequest($url);
        if (!$res || empty($res['body'])) {
            return [
                'chart' => $fallbackGenerator($basePrice, $range),
                'table' => self::generateFallbackTable($basePrice),
                'source' => 'local_fallback',
                'isLive' => false
            ];
        }

        $json = @json_decode($res['body'], true);
        if (!is_array($json) || empty($json['values']) || !is_array($json['values'])) {
            return [
                'chart' => $fallbackGenerator($basePrice, $range),
                'table' => self::generateFallbackTable($basePrice),
                'source' => 'local_fallback',
                'isLive' => false
            ];
        }

        // Values arrive newest first -> reverse for ascending chart timeline
        $rawValues = array_reverse($json['values']);
        $points = [];
        foreach ($rawValues as $v) {
            $dt = $v['datetime'] ?? '';
            $dateLabel = self::formatDateLabel($dt, $range);
            $points[] = [
                'date' => $dateLabel,
                'open' => (float)$v['open'],
                'high' => (float)$v['high'],
                'low' => (float)$v['low'],
                'close' => (float)$v['close'],
                'volume' => isset($v['volume']) ? (int)$v['volume'] : 0,
            ];
        }

        // Also build the 5-day table dataset (from the latest daily entries if available)
        $tableData = [];
        $latestFive = array_slice($json['values'], 0, 5);
        foreach ($latestFive as $v) {
            $dt = $v['datetime'] ?? '';
            $tableData[] = [
                'date' => date('d M Y', strtotime($dt)),
                'open' => (float)$v['open'],
                'high' => (float)$v['high'],
                'low' => (float)$v['low'],
                'close' => (float)$v['close'],
                'volume' => number_format((int)($v['volume'] ?? 0))
            ];
        }

        $result = [
            'chart' => $points,
            'table' => $tableData,
            'source' => 'twelve_data_live',
            'isLive' => true
        ];

        @file_put_contents($cacheFile, json_encode($result, JSON_PRETTY_PRINT));
        return $result;
    }

    /**
     * Search symbols using Twelve Data symbol_search.
     */
    public static function searchSymbols(string $query): array {
        self::init();
        $query = trim($query);
        if ($query === '' || !self::isConfigured()) {
            return [];
        }

        $cleanQuery = preg_replace('/[^A-Za-z0-9_-]/', '', $query);
        $cacheFile = self::$cacheDir . "/search_{$cleanQuery}.json";
        if (file_exists($cacheFile) && (time() - filemtime($cacheFile) < 3600)) {
            $cached = @json_decode(file_get_contents($cacheFile), true);
            if (is_array($cached)) {
                return $cached;
            }
        }

        $url = 'https://api.twelvedata.com/symbol_search?' . http_build_query([
            'symbol' => $query,
            'outputsize' => 10,
            'apikey' => self::$apiKey
        ]);

        $res = self::makeHttpRequest($url);
        if (!$res || empty($res['body'])) {
            return [];
        }

        $json = @json_decode($res['body'], true);
        if (!is_array($json) || empty($json['data']) || !is_array($json['data'])) {
            return [];
        }

        $results = [];
        foreach ($json['data'] as $item) {
            $results[] = [
                'symbol' => $item['symbol'] ?? '',
                'companyName' => $item['instrument_name'] ?? ($item['symbol'] ?? ''),
                'exchange' => $item['exchange'] ?? '',
                'country' => $item['country'] ?? 'Global',
                'currency' => $item['currency'] ?? 'USD',
                'sector' => $item['instrument_type'] ?? 'Equities'
            ];
        }

        @file_put_contents($cacheFile, json_encode($results, JSON_PRETTY_PRINT));
        return $results;
    }

    /**
     * Clears all cached Twelve Data files.
     */
    public static function clearCache(): bool {
        if (!is_dir(self::$cacheDir)) return true;
        $files = glob(self::$cacheDir . '/*.json');
        foreach ($files as $file) {
            @unlink($file);
        }
        return true;
    }

    /**
     * Helper to format datetime string based on selected chart range.
     */
    private static function formatDateLabel(string $dt, string $range): string {
        $timestamp = strtotime($dt);
        if (!$timestamp) {
            return $dt;
        }

        switch ($range) {
            case '1D':
                return date('H:i', $timestamp);
            case '1W':
            case '1M':
            case '3M':
                return date('d M', $timestamp);
            case '1Y':
            case '5Y':
            case 'ALL':
            default:
                return date('M Y', $timestamp);
        }
    }

    /**
     * Generates a 5-day fallback table for stock history breakdown.
     */
    private static function generateFallbackTable(float $basePrice): array {
        $today = new DateTime();
        $tableData = [];
        for ($i = 0; $i < 5; $i++) {
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
        return $tableData;
    }

    /**
     * Performs an outbound HTTP GET request using cURL with resilient timeouts.
     */
    private static function makeHttpRequest(string $url): ?array {
        if (!function_exists('curl_init')) {
            return null;
        }

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 3);
        curl_setopt($ch, CURLOPT_TIMEOUT, 6);
        curl_setopt($ch, CURLOPT_USERAGENT, 'MarketPulse/2.0 (Financial App)');
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false); // For local dev environments
        curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, 0);

        $body = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $error = curl_error($ch);
        curl_close($ch);

        if ($error || $httpCode >= 400) {
            return null;
        }

        return [
            'status' => $httpCode,
            'body' => $body
        ];
    }

    /**
     * Simple parser for .env files without requiring composer dependencies.
     */
    private static function loadEnvFile(string $path): void {
        if (!file_exists($path) || !is_readable($path)) {
            return;
        }

        $lines = @file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
        if (!$lines) return;

        foreach ($lines as $line) {
            $line = trim($line);
            if ($line === '' || str_starts_with($line, '#')) {
                continue;
            }
            if (strpos($line, '=') !== false) {
                list($k, $v) = explode('=', $line, 2);
                $k = trim($k);
                $v = trim($v, " \t\n\r\0\x0B\"'");
                if (!isset($_ENV[$k])) {
                    $_ENV[$k] = $v;
                }
                if (!getenv($k)) {
                    putenv("$k=$v");
                }
            }
        }
    }
}
