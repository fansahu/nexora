import 'package:flutter/material.dart';
import 'tmdb.dart';
import 'ui.dart';
import 'details.dart';
import 'store.dart';

void _open(BuildContext c, Item i) =>
    Navigator.push(c, MaterialPageRoute(builder: (_) => DetailsScreen(item: i)));

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final r = Store.region;
    return Scaffold(
      appBar: AppBar(
        title: const Text('NEXORA',
            style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.w900, color: Color(0xFFE50914))),
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: ListView(
          children: [
            Rail('Trending India', Tmdb.list('/trending/movie/week', {'region': r}), onTap: (i) => _open(context, i)),
            Rail('Hindi Movies',
                Tmdb.list('/discover/movie', {'with_original_language': 'hi', 'sort_by': 'popularity.desc', 'region': r}),
                onTap: (i) => _open(context, i)),
            Rail('Hindi Web Series',
                Tmdb.list('/discover/tv', {'with_original_language': 'hi', 'sort_by': 'popularity.desc'}),
                onTap: (i) => _open(context, i)),
            Rail('Hollywood',
                Tmdb.list('/discover/movie', {'with_original_language': 'en', 'sort_by': 'popularity.desc', 'region': r}),
                onTap: (i) => _open(context, i)),
            Rail('South Indian',
                Tmdb.list('/discover/movie', {'with_original_language': 'te|ta|ml|kn', 'sort_by': 'popularity.desc'}),
                onTap: (i) => _open(context, i)),
            Rail('Top Rated', Tmdb.list('/movie/top_rated'), onTap: (i) => _open(context, i)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _c = TextEditingController();
  Future<List<Item>>? _f;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _c,
          decoration: const InputDecoration(hintText: 'Movie, series, actor...', border: InputBorder.none),
          onSubmitted: (v) => setState(() => _f = v.trim().isEmpty ? null : Tmdb.list('/search/multi', {'query': v})),
        ),
      ),
      body: FutureBuilder<List<Item>>(
        future: _f,
        builder: (c, s) {
          if (_f == null) return const Center(child: Text('Kuch search karo'));
          if (s.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (s.hasError) return Msg(s.error);
          final l = (s.data ?? []).where((e) => e.type == 'movie' || e.type == 'tv').toList();
          return GridView.builder(
            padding: const EdgeInsets.all(14),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.55),
            itemCount: l.length,
            itemBuilder: (_, i) => GestureDetector(onTap: () => _open(context, l[i]), child: Poster(l[i], w: 200)),
          );
        },
      ),
    );
  }
}

class AdultScreen extends StatefulWidget {
  const AdultScreen({super.key});
  @override
  State<AdultScreen> createState() => _AdultScreenState();
}

class _AdultScreenState extends State<AdultScreen> {
  Future<List<Item>>? _f;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _f = Tmdb.list('/discover/movie', {
      'include_adult': 'true',
      'sort_by': 'popularity.desc',
      'with_original_language': 'hi|en',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('18+ Zone')),
      body: FutureBuilder<List<Item>>(
        future: _f,
        builder: (c, s) {
          if (s.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (s.hasError) return Msg(s.error);
          final l = s.data ?? [];
          return GridView.builder(
            padding: const EdgeInsets.all(14),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.55),
            itemCount: l.length,
            itemBuilder: (_, i) => GestureDetector(onTap: () => _open(context, l[i]), child: Poster(l[i], w: 200)),
          );
        },
      ),
    );
  }
}
