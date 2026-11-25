import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'details.dart';

class CategoryScreen extends StatefulWidget {
  final String title;
  final String endpoint;
  final String type;
  const CategoryScreen({super.key, required this.title, required this.endpoint, required this.type});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String apiKey = '';
  List<dynamic> items = [];
  List<dynamic> filteredItems = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      apiKey = p.getString('tmdb_key') ?? '';
      _fetchCategory();
    });
  }

  void _fetchCategory() async {
    if (apiKey.isEmpty) return setState(() => isLoading = false);
    final res = await http.get(Uri.parse('https://api.themoviedb.org/3${widget.endpoint}&api_key=$apiKey'));
    if (res.statusCode == 200) {
      setState(() {
        items = json.decode(res.body)['results'] ?? [];
        filteredItems = items;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  void _search(String query) {
    if (query.isEmpty) {
      setState(() => filteredItems = items);
    } else {
      setState(() {
        filteredItems = items.where((item) {
          final title = (item['title'] ?? item['name'] ?? '').toString().toLowerCase();
          return title.contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search in ${widget.title}...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: _search,
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : filteredItems.isEmpty
              ? const Center(child: Text('No results found', style: TextStyle(color: Colors.grey)))
              : GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.6,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final m = filteredItems[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailsScreen(
                            id: m['id'],
                            type: widget.type,
                            posterPath: m['poster_path'],
                          ),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: m['poster_path'] != null
                            ? Image.network(
                                'https://image.tmdb.org/t/p/w200${m['poster_path']}',
                                fit: BoxFit.cover,
                              )
                            : Container(color: Colors.grey[800], child: const Icon(Icons.movie, color: Colors.grey)),
                      ),
                    );
                  },
                ),
    );
  }
}
