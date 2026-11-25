import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'details.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String apiKey = '';
  String selectedCategory = 'South';
  List<dynamic> continueWatching = [];

  final Map<String, String> categories = {
    'South': '/discover/movie?with_original_language=te,ta,ml,kn&sort_by=popularity.desc',
    'Korean': '/discover/movie?with_original_language=ko&sort_by=popularity.desc',
    'Hollywood': '/discover/movie?with_original_language=en&sort_by=popularity.desc',
    'Bollywood': '/discover/movie?with_original_language=hi&sort_by=popularity.desc',
    'Series': '/discover/tv?sort_by=popularity.desc',
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString('tmdb_key') ?? '';
    final history = prefs.getStringList('history') ?? [];
    List<dynamic> historyData = [];
    for (var item in history) {
      historyData.add(json.decode(item));
    }
    setState(() {
      apiKey = key;
      continueWatching = historyData;
    });
  }

  Future<List<dynamic>> fetchMovies(String url) async {
    if (apiKey.isEmpty) return [];
    final res = await http.get(Uri.parse('https://api.themoviedb.org/3$url&api_key=$apiKey'));
    if (res.statusCode == 200) return json.decode(res.body)['results'] ?? [];
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NEXORA', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, letterSpacing: 2)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: categories.keys.map((cat) {
                bool isSel = cat == selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSel,
                    selectedColor: Colors.redAccent,
                    backgroundColor: Colors.grey[800],
                    labelStyle: TextStyle(color: isSel ? Colors.white : Colors.grey),
                    onSelected: (s) => setState(() => selectedCategory = cat),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body: apiKey.isEmpty
          ? const Center(child: Text('Set TMDB API Key in Settings', style: TextStyle(color: Colors.white)))
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                children: [
                  if (continueWatching.isNotEmpty)
                    _buildRail('Continue Watching', continueWatching, isHistory: true),
                  _buildFutureRail('Popular $selectedCategory', categories[selectedCategory]!),
                  _buildFutureRail('Top Rated $selectedCategory', categories[selectedCategory]!.replaceAll('popularity.desc', 'vote_average.desc')),
                ],
              ),
            ),
    );
  }

  Widget _buildFutureRail(String title, String endpoint) {
    return FutureBuilder<List<dynamic>>(
      future: fetchMovies(endpoint),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox();
        return _buildRail(title, snapshot.data!);
      },
    );
  }

  Widget _buildRail(String title, List<dynamic> movies, {bool isHistory = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final m = movies[index];
              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailsScreen(
                  id: m['id'], 
                  type: m['name'] != null || isHistory && m['media_type'] == 'tv' ? 'tv' : 'movie',
                  posterPath: m['poster_path'],
                ))),
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      Expanded(
                        child: Hero(
                          tag: 'poster_${m['id']}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: m['poster_path'] != null
                                ? Image.network('https://image.tmdb.org/t/p/w200${m['poster_path']}', fit: BoxFit.cover)
                                : Container(color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(m['title'] ?? m['name'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
