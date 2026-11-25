import 'package:flutter/material.dart';
import 'category_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'title': 'South Movies', 'endpoint': '/discover/movie?with_original_language=te|ta|ml|kn&sort_by=popularity.desc', 'type': 'movie'},
      {'title': 'Bollywood', 'endpoint': '/discover/movie?with_original_language=hi&sort_by=popularity.desc', 'type': 'movie'},
      {'title': 'Hollywood', 'endpoint': '/discover/movie?with_original_language=en&sort_by=popularity.desc', 'type': 'movie'},
      {'title': 'Korean Movies', 'endpoint': '/discover/movie?with_original_language=ko&sort_by=popularity.desc', 'type': 'movie'},
      {'title': 'Web Series', 'endpoint': '/discover/tv?sort_by=popularity.desc', 'type': 'tv'},
      {'title': 'Korean Series', 'endpoint': '/discover/tv?with_original_language=ko&sort_by=popularity.desc', 'type': 'tv'},
      {'title': 'Indian Series', 'endpoint': '/discover/tv?with_original_language=hi|ta|te&sort_by=popularity.desc', 'type': 'tv'},
      {'title': 'Top Rated', 'endpoint': '/movie/top_rated', 'type': 'movie'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('NEXORA', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, letterSpacing: 2)),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CategoryScreen(
                  title: cat['title']!,
                  endpoint: cat['endpoint']!,
                  type: cat['type']!,
                ),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.grey[900]!, Colors.black], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
              ),
              child: Center(
                child: Text(
                  cat['title']!,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
