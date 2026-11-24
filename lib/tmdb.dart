import 'dart:convert';
import 'package:http/http.dart' as http;
import 'store.dart';

class Item {
  final int id;
  final String title;
  final String? poster;
  final String? backdrop;
  final String? overview;
  final String type;
  final String? date;
  final double vote;

  Item.fromJson(Map<String, dynamic> j)
      : id = j['id'] as int,
        title = (j['title'] ?? j['name'] ?? 'Untitled') as String,
        poster = j['poster_path'] as String?,
        backdrop = j['backdrop_path'] as String?,
        overview = j['overview'] as String?,
        type = (j['media_type'] ?? (j.containsKey('first_air_date') ? 'tv' : 'movie')) as String,
        date = (j['release_date'] ?? j['first_air_date']) as String?,
        vote = ((j['vote_average'] ?? 0) as num).toDouble();
}

class Tmdb {
  static const _base = 'https://api.themoviedb.org/3';

  static Future<Map<String, dynamic>> _get(String path, [Map<String, String>? q]) async {
    final key = Store.tmdbKey;
    if (key.isEmpty) throw 'TMDB key set nahi hai. Settings me daalo.';
    final uri = Uri.parse('$_base$path').replace(queryParameters: {
      'api_key': key,
      'language': Store.uiLang,
      'include_adult': Store.adult ? 'true' : 'false',
      ...?q,
    });
    final r = await http.get(uri).timeout(const Duration(seconds: 20));
    if (r.statusCode != 200) throw 'TMDB ${r.statusCode}';
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  static Future<List<Item>> list(String path, [Map<String, String>? q]) async {
    final j = await _get(path, q);
    return (j['results'] as List? ?? []).map((e) => Item.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<Item> detail(int id, String type) async =>
      Item.fromJson(await _get('/$type/$id'));

  static Future<List<Map<String, dynamic>>> cast(int id, String type) async {
    final j = await _get('/$type/$id/credits');
    return (j['cast'] as List? ?? []).take(12).cast<Map<String, dynamic>>().toList();
  }

  static Future<List<Map<String, dynamic>>> episodes(int id, int season) async {
    final j = await _get('/tv/$id/season/$season');
    return (j['episodes'] as List? ?? []).cast<Map<String, dynamic>>().toList();
  }

  static const posterBase = 'https://image.tmdb.org/t/p/w342';
  static const backdropBase = 'https://image.tmdb.org/t/p/w780';
}
