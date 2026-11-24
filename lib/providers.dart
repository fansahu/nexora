import 'store.dart';

// Ek server ka description
class Provider {
  final String name;   // screen par dikhne wala naam
  final bool adult;    // 18+ content serve karta hai?
  final String Function(int id, int season, int episode, bool isTv) build;

  const Provider(this.name, this.build, {this.adult = false});
}

// URL ke end me audio/subtitle/quality params jodo
String _p(String url) {
  final sep = url.contains('?') ? '&' : '?';
  return '$url${sep}audio=${Store.audio}&sub=${Store.sub}&quality=${Store.quality}';
}

class Servers {
  // const nahi, final — kyunki andar closures hain
  static final List<Provider> all = <Provider>[
    Provider('VidLink', (id, s, e, tv) =>
        _p(tv ? 'https://vidlink.pro/tv/$id/$s/$e' : 'https://vidlink.pro/movie/$id')),
    Provider('EmbedWave', (id, s, e, tv) =>
        _p(tv ? 'https://embedwave.cc/embed/tv/$id/$s/$e' : 'https://embedwave.cc/embed/movie/$id')),
    Provider('Videasy', (id, s, e, tv) =>
        _p(tv ? 'https://player.videasy.net/tv/$id/$s/$e' : 'https://player.videasy.net/movie/$id')),
    Provider('VixSrc', (id, s, e, tv) =>
        _p(tv ? 'https://vixsrc.to/tv/$id/$s/$e' : 'https://vixsrc.to/movie/$id')),
    Provider('VidSrc.to', (id, s, e, tv) =>
        _p(tv ? 'https://vidsrc.to/embed/tv/$id/$s/$e' : 'https://vidsrc.to/embed/movie/$id'),
        adult: true),
    Provider('VidSrc.icu', (id, s, e, tv) =>
        _p(tv ? 'https://vidsrc.icu/embed/tv/$id/$s/$e' : 'https://vidsrc.icu/embed/movie/$id'),
        adult: true),
    // 2Embed apne params & se leta hai, isliye yahan _p() nahi lagaya
    Provider('2Embed', (id, s, e, tv) =>
        tv ? 'https://www.2embed.cc/embedtv/$id&s=$s&e=$e' : 'https://www.2embed.cc/embed/$id'),
    Provider('SuperEmbed', (id, s, e, tv) =>
        _p('https://multiembed.mov/?video_id=$id&tmdb=1${tv ? '&s=$s&e=$e' : ''}')),
    Provider('MoviesAPI', (id, s, e, tv) =>
        _p(tv ? 'https://moviesapi.club/tv/$id-$s-$e' : 'https://moviesapi.club/movie/$id')),
    Provider('AutoEmbed', (id, s, e, tv) =>
        _p(tv ? 'https://player.autoembed.cc/embed/tv/$id/$s/$e' : 'https://player.autoembed.cc/embed/movie/$id')),
    Provider('VidSrc.me', (id, s, e, tv) =>
        _p('https://vidsrc.me/embed/$id?tmdb=1${tv ? '&s=$s&e=$e' : ''}')),
  ];

  // Settings me band kiye hue hata do. Sab band ho gaye to poora list wapas.
  // adultFirst: 18+ title ke liye adult-capable server upar.
  static List<Provider> ordered({bool adultFirst = false}) {
    final enabled = all.where((p) => !Store.disabled.contains(p.name)).toList();
    final list = enabled.isEmpty ? List<Provider>.from(all) : enabled;
    if (adultFirst) {
      list.sort((a, b) => (b.adult ? 1 : 0) - (a.adult ? 1 : 0));
    }
    return list;
  }

  static int indexOf(List<Provider> list, String name) =>
      list.indexWhere((p) => p.name == name);
}
