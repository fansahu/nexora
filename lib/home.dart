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
    // Proper URL encode for TMDB API
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
      ),
      body: apiKey.isEmpty
          ? const Center(child: Text('Set TMDB API Key in Settings', style: TextStyle(color: Colors.white)))
          : RefreshIndicator(
              onRefresh: () async => setState(() {}),
              child: ListView(
                children: [
                  // Fix 1: comma separated languages for South Indian
                  _buildRail('South Indian', '/discover/movie?with_original_language=te,ta,ml,kn&sort_by=popularity.desc'),
                  // Fix 2: Top rated
                  _buildRail('Top Rated', '/movie/top_rated'),
                  _buildRail('Action Movies', '/discover/movie?with_genres=28'),
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
          padding: const EdgeInsets.all(16.0),
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
                // Ab error screen pe dikhega (red text)
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
                  return GestureDetector(
                    onTap: () {
                      // Yahan player ka URL dalna hoga. Filhal TMDB ID use karke open kar rahe hain
                      Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(videoUrl: 'https://vidlink.pro/movie/${movie['id']}')));
                    },
                    child: Container(
                      width: 120,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: movie['poster_path'] != null
                                  ? Image.network('https://image.tmdb.org/t/p/w200${movie['poster_path']}', fit: BoxFit.cover)
                                  : Container(color: Colors.grey),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            movie['title'] ?? movie['name'] ?? 'No Title',
                            maxLines: 2,
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
