import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String apiKey = '';
  String selectedCategory = 'South'; // Default category

  // Categories aur unke API endpoints
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
    _loadKey();
  }

  Future<void> _loadKey() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => apiKey = prefs.getString('tmdb_key') ?? '');
  }

  Future<List<dynamic>> fetchMovies(String url) async {
    if (apiKey.isEmpty) return [];
    final response = await http.get(Uri.parse('https://api.themoviedb.org/3$url&api_key=$apiKey'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['results'] ?? [];
    } else {
      throw Exception('Failed to load: ${response.statusCode}');
    }
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
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final catName = categories.keys.elementAt(index);
                final isSelected = catName == selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(catName),
                    selected: isSelected,
                    selectedColor: Colors.redAccent,
                    backgroundColor: Colors.grey[800],
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => selectedCategory = catName);
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: apiKey.isEmpty
          ? const Center(child: Text('Set TMDB API Key in Settings', style: TextStyle(color: Colors.white)))
          : RefreshIndicator(
              onRefresh: () async => setState(() {}),
              child: ListView(
                children: [
                  // Agar category Series hai to uske alag section ho sakte hain, 
                  // filhal yahan hum Popularity aur Top Rated dikha rahe hain.
                  _buildRail('Popular $selectedCategory', categories[selectedCategory]!),
                  
                  // Series ke liye alag genre specific ya top rated
                  if (selectedCategory == 'Series')
                    _buildRail('Top Rated Series', '/tv/top_rated')
                  else
                    _buildRail('Top Rated $selectedCategory', categories[selectedCategory]!.replaceAll('popularity.desc', 'vote_average.desc')),
                    
                  if (selectedCategory != 'Series')
                    _buildRail('Action $selectedCategory', '${categories[selectedCategory]!.split('?')[0]}?with_original_language=${categories[selectedCategory]!.split('with_original_language=')[1].split('&')[0]}&with_genres=28'),
                ],
              ),
            ),
    );
  }

  Widget _buildRail(String title, String endpoint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        SizedBox(
          height: 200,
          child: FutureBuilder<List<dynamic>>(
            future: fetchMovies(endpoint),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent, fontSize: 12)));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No content found', style: TextStyle(color: Colors.grey)));
              }
              final movies = snapshot.data!;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  final titleStr = movie['title'] ?? movie['name'] ?? 'No Title';
                  final poster = movie['poster_path'];
                  
                  return GestureDetector(
                    onTap: () {
                      // Player me bhej rahe hain. Series ke liye URL alag hoga.
                      final type = selectedCategory == 'Series' ? 'tv' : 'movie';
                      Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(videoUrl: 'https://vidlink.pro/$type/${movie['id']}')));
                    },
                    child: Container(
                      width: 120,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: poster != null
                                  ? Image.network('https://image.tmdb.org/t/p/w200$poster', fit: BoxFit.cover)
                                  : Container(color: Colors.grey),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            titleStr,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
