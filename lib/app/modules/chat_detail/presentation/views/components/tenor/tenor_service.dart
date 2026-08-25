import 'dart:convert';
import 'dart:io';

class TenorGif {
  final Map<String, dynamic> raw;
  final String id;
  final String? tinyGifUrl;
  final String? gifUrl;
  final String? mp4Url;
  final double aspectRatio;

  TenorGif(
      {required this.raw,
      required this.id,
      this.tinyGifUrl,
      this.gifUrl,
      this.mp4Url,
      this.aspectRatio = 1.0});

  factory TenorGif.fromJson(Map<String, dynamic> j) {
    final fmts = j['media_formats'] ?? {};
    final dims = (fmts['tinygif']?['dims'] ?? fmts['gif']?['dims']) as List?;
    final ar = (dims != null && dims.length == 2)
        ? (dims[0] as num) / (dims[1] as num)
        : 1.0;
    return TenorGif(
      raw: j,
      id: j['id']?.toString() ?? '',
      tinyGifUrl: fmts['tinygif']?['url'],
      gifUrl: fmts['gif']?['url'],
      mp4Url: fmts['mp4']?['url'],
      aspectRatio: (ar.isFinite && ar > 0) ? ar.toDouble() : 1.0,
    );
  }
}

class TenorPage {
  final List<TenorGif> items;
  final String? next;
  TenorPage(this.items, this.next);
}

class TenorService {
  static const _host = 'tenor.googleapis.com';
  final String apiKey;
  final String clientKey;
  final String? locale;

  TenorService({required this.apiKey, required this.clientKey, this.locale});

  Future<TenorPage> fetch({String? query, String? pos, int limit = 30}) async {
    final endpoint = (query == null || query.isEmpty) ? 'featured' : 'search';
    final params = {
      'key': apiKey,
      'client_key': clientKey,
      'limit': '$limit',
      'media_filter': 'minimal',
      'contentfilter': 'high',
      if (query != null && query.isNotEmpty) 'q': query,
      if (pos != null) 'pos': pos,
      if (locale != null) 'locale': locale!,
    };
    final uri = Uri.https(_host, '/v2/$endpoint', params);

    final client = HttpClient()..autoUncompress = true;
    try {
      final req = await client.getUrl(uri);
      req.followRedirects = true;
      req.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final res = await req.close();
      if (res.statusCode != HttpStatus.ok) {
        throw Exception('Tenor ${res.statusCode}: ${res.reasonPhrase}');
      }
      final body = await utf8.decoder.bind(res).join();
      final map = jsonDecode(body) as Map<String, dynamic>;
      final items = (map['results'] as List? ?? [])
          .map((e) => TenorGif.fromJson(e as Map<String, dynamic>))
          .toList();
      return TenorPage(items, map['next'] as String?);
    } finally {
      client.close();
    }
  }
}
