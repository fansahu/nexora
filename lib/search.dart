import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'details.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String apiKey = '';
  String query = '';
  List<dynamic> results = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) => setState(() => apiKey = p.getString('tmdb_key') ?? ''));
  }

  void _search(String q) async {
    if (q.isEmpty || apiKey.isEmpty) {
      setState(() => results = []);
      return;
    }
    setState(() => isLoading = true);
    final res = await http.get(Uri.parse('https://api.themoviedb.org/3/search/multi?query=$q&api_key=$apiKey'));
    if (res.statusCode == 200) {
      setState(() {
        results = json.decode(res.body)['results']?.where((e) => e['media_type'] != 'person').toList() ?? [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: const InputDecoration(hintText: 'Search Movies, Series...', border: InputBorder.none),
          style: const TextStyle(color: Colors.white),
          onChanged: _search,
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.6, crossAxisSpacing: 10, mainAxisSpacing: 10),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final m = results[index];
                final type = m['media_type'] ?? 'movie';
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailsScreen(id: m['id'], type: type, posterPath: m['poster_path']))),
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
