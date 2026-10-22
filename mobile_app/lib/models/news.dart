class NewsArticle {
  final int id;
  final String title;
  final String source;
  final String time;
  final String symbol;
  final String country;
  final String url;
  final String summary;

  NewsArticle({
    required this.id,
    required this.title,
    required this.source,
    required this.time,
    required this.symbol,
    required this.country,
    required this.url,
    required this.summary,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] ?? '',
      source: json['source'] ?? 'MarketPulse News',
      time: json['time'] ?? 'Recently',
      symbol: json['symbol'] ?? 'MARKET',
      country: json['country'] ?? 'Global',
      url: json['url'] ?? 'https://www.ft.com',
      summary: json['summary'] ?? '',
    );
  }
}
