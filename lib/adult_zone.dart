import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdultZoneScreen extends StatefulWidget {
  const AdultZoneScreen({super.key});

  @override
  State<AdultZoneScreen> createState() => _AdultZoneScreenState();
}

class _AdultZoneScreenState extends State<AdultZoneScreen> {
  List<dynamic> _results = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchAdultContent();
  }

  Future<void> _fetchAdultContent() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('tmdb_key') ?? '';
    
    if (apiKey.isEmpty) {
      setState(() => _loading = false);
      return;
    }

    // TMDB me adult content ke liye specific tag use hote hain. 
    // Yeh ek example endpoint hai. Tum apne hisaab se customize kar lena.
    final url = Uri.parse('https://api.themoviedb.org/3/discover/movie?api_key=$apiKey&include_adult=true&with_genres=10749&sort_by=popularity.desc');
    
    try {
      final res = await http.get(url);
      final data = json.decode(res.body);
      setState(() {
        _results = data['results'] ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
    if (_results.isEmpty) return const Center(child: Text('No 18+ content found. Check API Key.', style: TextStyle(color: Colors.white)));

    return Scaffold(
      appBar: AppBar(title: const Text('18+ HARD ZONE', style: TextStyle(color: Colors.redAccent))),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.7,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _results.length,
        itemBuilder: (context, index) {
          final movie = _results[index];
          final poster = movie['poster_path'] != null 
              ? 'https://image.tmdb.org/t/p/w500${movie['poster_path']}' 
              : '';
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(8),
              image: poster.isNotEmpty ? DecorationImage(image: NetworkImage(poster), fit: BoxFit.cover) : null,
            ),
          );
        },
      ),
    );
  }
}
