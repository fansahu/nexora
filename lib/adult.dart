import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'details.dart';

class AdultScreen extends StatefulWidget {
  const AdultScreen({super.key});
  @override
  State<AdultScreen> createState() => _AdultScreenState();
}

class _AdultScreenState extends State<AdultScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String apiKey = '';
  List<dynamic> movies = [];
  List<dynamic> series = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    SharedPreferences.getInstance().then((p) {
      apiKey = p.getString('tmdb_key') ?? '';
      _fetchAll();
    });
  }

  void _fetchAll() async {
    if (apiKey.isEmpty) return setState(() => isLoading = false);
    try {
      // 1. Fetch NC-17 Movies (Hollywood Adult)
      final movieRes = await http.get(Uri.parse('https://api.themoviedb.org/3/discover/movie?include_adult=true&certification_country=US&certification=NC-17&sort_by=popularity.desc&api_key=$apiKey')).timeout(const Duration(seconds: 15));
      
      // 2. Fetch Indian Adult Web Series (Ullu, AltBalaji type - using Drama genre + Hindi language + Adult flag)
      final seriesRes = await http.get(Uri.parse('https://api.themoviedb.org/3/discover/tv?include_adult=true&with_original_language=hi&with_genres=18&sort_by=popularity.desc&api_key=$apiKey')).timeout(const Duration(seconds: 15));
      
      setState(() {
        if (movieRes.statusCode == 200) movies = json.decode(movieRes.body)['results'] ?? [];
        if (seriesRes.statusCode == 200) series = json.decode(seriesRes.body)['results'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Widget _buildGrid(List<dynamic> list, String type) {
    if (list.isEmpty) return const Center(child: Text('No content found.', style: TextStyle(color: Colors.grey)));
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.6, crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final m = list[index];
        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => DetailsScreen(id: m['id'], type: type, posterPath: m['poster_path'])
          )),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: m['poster_path'] != null
                ? CachedNetworkImage(
                    imageUrl: 'https://image.tmdb.org/t/p/w200${m['poster_path']}', 
                    fit: BoxFit.cover,
                    placeholder: (c, u) => Container(color: Colors.grey[900]),
                  )
                : Container(color: Colors.grey[800], child: const Icon(Icons.movie, color: Colors.grey)),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('18+ Zone', style: TextStyle(color: Colors.redAccent)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.redAccent,
          labelColor: Colors.redAccent,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Adult Movies'),
            Tab(text: 'Web Series (Ullu)'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildGrid(movies, 'movie'),
                _buildGrid(series, 'tv'),
              ],
            ),
    );
  }
}
