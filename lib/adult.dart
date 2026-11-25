import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'details.dart';

class AdultScreen extends StatefulWidget {
  const AdultScreen({super.key});
  @override
  State<AdultScreen> createState() => _AdultScreenState();
}

class _AdultScreenState extends State<AdultScreen> {
  String apiKey = '';
  List<dynamic> movies = [];

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      apiKey = p.getString('tmdb_key') ?? '';
      _fetch();
    });
  }

  void _fetch() async {
    if (apiKey.isEmpty) return;
    // Adult (NC-17 / R) hardcore content fetch
    final res = await http.get(Uri.parse('https://api.themoviedb.org/3/discover/movie?include_adult=true&certification_country=US&certification=NC-17&sort_by=popularity.desc&api_key=$apiKey'));
    if (res.statusCode == 200) {
      setState(() => movies = json.decode(res.body)['results'] ?? []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('18+ Hardcore Zone', style: TextStyle(color: Colors.redAccent))),
      body: movies.isEmpty 
          ? const Center(child: Text('Fetching Adult Content...', style: TextStyle(color: Colors.grey)))
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.6, crossAxisSpacing: 10, mainAxisSpacing: 10),
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final m = movies[index];
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailsScreen(id: m['id'], type: 'movie', posterPath: m['poster_path']))),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: m['poster_path'] != null
                        ? Image.network('https://image.tmdb.org/t/p/w200${m['poster_path']}', fit: BoxFit.cover)
                        : Container(color: Colors.grey),
                  ),
                );
              },
            ),
    );
  }
}
