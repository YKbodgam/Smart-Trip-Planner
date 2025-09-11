/// Model class for search results from web searches
class SearchResult {
  final String title;
  final String snippet;
  final String url;
  final String displayLink;
  final String? source;
  final DateTime? publishedTime;

  const SearchResult({
    required this.title,
    required this.snippet,
    required this.url,
    required this.displayLink,
    this.source,
    this.publishedTime,
  });
}
