import 'package:flutter/material.dart';
import 'tmdb.dart';
import 'player.dart';

class DetailsScreen extends StatefulWidget {
  final Item item;
  const DetailsScreen({super.key, required this.item});
  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  int _season = 1;
  int _episodes = 0;

  bool get _tv => widget.item.type == 'tv';

  void _play({int? ep}) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(
      id: widget.item.id,
      type: widget.item.type,
      title: widget.item.title,
      season: _season,
      episode: ep ?? 1,
    )));
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.item.backdrop;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: b == null
                  ? Container(color: Colors.black)
                  : Image.network('${Tmdb.backdropBase}$b', fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: Colors.black)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.item.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('${widget.item.date ?? '-'}  •  ⭐ ${widget.item.vote.toStringAsFixed(1)}'),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: () => _play(),
                    icon: const Icon(Icons.play_arrow),
                    label: Text(_tv ? 'Season $_season, Ep 1 se shuru' : 'Play'),
                  ),
                  const SizedBox(height: 16),
                  Text(widget.item.overview ?? ''),
                  const SizedBox(height: 16),
                  if (_tv) ...[
                    Row(
                      children: [
                        const Text('Season: '),
                        DropdownButton<int>(
                          value: _season,
                          items: List.generate(10, (i) => i + 1)
                              .map((s) => DropdownMenuItem(value: s, child: Text('$s')))
                              .toList(),
                          onChanged: (v) => setState(() { _season = v!; _episodes = 0; }),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () async {
                            final e = await Tmdb.episodes(widget.item.id, _season);
                            setState(() => _episodes = e.length);
                          },
                          child: const Text('Episodes load karo'),
                        ),
                      ],
                    ),
                    if (_episodes > 0)
                      Wrap(
                        spacing: 8,
                        children: List.generate(_episodes, (i) => ActionChip(
                          label: Text('EP ${i + 1}'),
                          onPressed: () => _play(ep: i + 1),
                        )),
                      ),
                  ],
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
