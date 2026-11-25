import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'player.dart';

class DetailsScreen extends StatefulWidget {
  final int id;
  final String type;
  final String? posterPath;

  const DetailsScreen({super.key, required this.id, required this.type, this.posterPath});
  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  Map<String, dynamic>? data;
  String apiKey = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    final prefs = await SharedPreferences.getInstance();
    apiKey = prefs.getString('tmdb_key') ?? '';
    final res = await http.get(Uri.parse('https://api.themoviedb.org/3/${widget.type}/${widget.id}?api_key=$apiKey'));
    if (res.statusCode == 200) setState(() => data = json.decode(res.body));
  }

  void _addToHistory() async {
    final prefs = await SharedPreferences.getInstance();
    var history = prefs.getStringList('history') ?? [];
    final item = json.encode({
      'id': widget.id,
      'media_type': widget.type,
      'poster_path': widget.posterPath,
      'title': data?['title'] ?? data?['name']
    });
    if (!history.contains(item)) history.insert(0, item);
    if (history.length > 10) history.removeLast();
    prefs.setStringList('history', history);
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator(color: Colors.redAccent)));
    
    return Scaffold(
      appBar: AppBar(title: Text(data!['title'] ?? data!['name'] ?? '')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data!['backdrop_path'] != null)
              Image.network('https://image.tmdb.org/t/p/w500${data!['backdrop_path']}', width: double.infinity, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Hero(
                        tag: 'poster_${widget.id}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: widget.posterPath != null 
                            ? Image.network('https://image.tmdb.org/t/p/w200${widget.posterPath}', width: 100) 
                            : const SizedBox(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data!['title'] ?? data!['name'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 8),
                            Text('⭐ ${data!['vote_average']} | ${data!['release_date'] ?? data!['first_air_date'] ?? ''}', style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(vertical: 16)),
                      icon: const Icon(Icons.play_arrow, color: Colors.white),
                      label: const Text('Watch Now', style: TextStyle(fontSize: 18, color: Colors.white)),
                      onPressed: () {
                        _addToHistory();
                        Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(id: widget.id, type: widget.type)));
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text(data!['overview'] ?? 'No overview available.', style: const TextStyle(color: Colors.grey, height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
