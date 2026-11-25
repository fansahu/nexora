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
  
  // Season/Episode variables
  List<dynamic> seasons = [];
  List<dynamic> episodes = [];
  int selectedSeason = 1;
  bool isLoadingEpisodes = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    final prefs = await SharedPreferences.getInstance();
    apiKey = prefs.getString('tmdb_key') ?? '';
    final res = await http.get(Uri.parse('https://api.themoviedb.org/3/${widget.type}/${widget.id}?api_key=$apiKey'));
    
    if (res.statusCode == 200) {
      setState(() {
        data = json.decode(res.body);
        if (widget.type == 'tv' && data!['seasons'] != null) {
          seasons = data!['seasons'];
          // First valid season select karo (0 skip karo kyunki wo specials hote hain)
          if (seasons.isNotEmpty) {
            var validSeason = seasons.firstWhere((s) => s['season_number'] != 0, orElse: () => seasons.first);
            selectedSeason = validSeason['season_number'];
            _loadEpisodes(selectedSeason);
          }
        }
      });
    }
  }

  void _loadEpisodes(int seasonNum) async {
    setState(() => isLoadingEpisodes = true);
    final res = await http.get(Uri.parse('https://api.themoviedb.org/3/tv/${widget.id}/season/$seasonNum?api_key=$apiKey'));
    if (res.statusCode == 200) {
      setState(() {
        episodes = json.decode(res.body)['episodes'] ?? [];
        isLoadingEpisodes = false;
      });
    } else {
      setState(() {
        episodes = [];
        isLoadingEpisodes = false;
      });
    }
  }

  void _addToHistory() async {
    final prefs = await SharedPreferences.getInstance();
    var history = prefs.getStringList('history') ?? [];
    final item = json.encode({
      'id': widget.id, 'media_type': widget.type, 'poster_path': widget.posterPath, 'title': data?['title'] ?? data?['name']
    });
    if (!history.contains(item)) history.insert(0, item);
    if (history.length > 10) history.removeLast();
    prefs.setStringList('history', history);
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator(color: Colors.redAccent)));
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.white)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Backdrop Image
            Stack(
              children: [
                if (data!['backdrop_path'] != null)
                  Image.network('https://image.tmdb.org/t/p/w780${data!['backdrop_path']}', width: double.infinity, height: 280, fit: BoxFit.cover)
                else
                  Container(height: 280, color: Colors.grey[900]),
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black]),
                    ),
                  ),
                ),
              ],
            ),
            
            // Poster & Title
            Transform.translate(
              offset: const Offset(0, -60),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'poster_${widget.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: widget.posterPath != null 
                          ? Image.network('https://image.tmdb.org/t/p/w200${widget.posterPath}', width: 110) 
                          : Container(width: 110, height: 165, color: Colors.grey[800]),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data!['title'] ?? data!['name'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.yellow, size: 18),
                              const SizedBox(width: 4),
                              Text('${data!['vote_average']}', style: const TextStyle(color: Colors.white, fontSize: 16)),
                              const SizedBox(width: 16),
                              Text(data!['release_date'] ?? data!['first_air_date'] ?? '', style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Overview & Watch Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.type == 'movie')
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        icon: const Icon(Icons.play_arrow, color: Colors.white),
                        label: const Text('Watch Now', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
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
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Episodes Section (Only for TV Series)
            if (widget.type == 'tv' && seasons.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Episodes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    DropdownButton<int>(
                      value: selectedSeason,
                      dropdownColor: Colors.grey[900],
                      style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                      underline: const SizedBox(),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.redAccent),
                      items: seasons.where((s) => s['season_number'] != 0).map<DropdownMenuItem<int>>((s) {
                        return DropdownMenuItem<int>(
                          value: s['season_number'],
                          child: Text('Season ${s['season_number']}'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => selectedSeason = val);
                          _loadEpisodes(val);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              if (isLoadingEpisodes)
                const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: Colors.redAccent)))
              else if (episodes.isEmpty)
                const Padding(padding: EdgeInsets.all(16), child: Text('No episodes found.', style: TextStyle(color: Colors.grey)))
              else
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: episodes.length,
                    itemBuilder: (context, index) {
                      final ep = episodes[index];
                      return GestureDetector(
                        onTap: () {
                          _addToHistory();
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => PlayerScreen(
                              id: widget.id, 
                              type: 'tv', 
                              season: selectedSeason, 
                              episode: ep['episode_number']
                            )
                          ));
                        },
                        child: Container(
                          width: 160,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                  child: ep['still_path'] != null
                                      ? Image.network('https://image.tmdb.org/t/p/w300${ep['still_path']}', width: double.infinity, fit: BoxFit.cover)
                                      : Container(color: Colors.grey[800], child: const Center(child: Icon(Icons.movie, color: Colors.grey))),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('E${ep['episode_number']}: ${ep['name']}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 40),
            ],
          ],
        ),
      ),
    );
  }
}
