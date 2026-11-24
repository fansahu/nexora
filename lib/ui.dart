import 'package:flutter/material.dart';
import 'tmdb.dart';

class Poster extends StatelessWidget {
  final Item item;
  final double w;
  const Poster(this.item, {super.key, this.w = 116});

  @override
  Widget build(BuildContext context) {
    final p = item.poster;
    return SizedBox(
      width: w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: 2 / 3,
              child: p == null
                  ? Container(color: Colors.grey.shade900, child: const Icon(Icons.movie, color: Colors.white24))
                  : Image.network('${Tmdb.posterBase}$p', fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade900)),
            ),
          ),
          const SizedBox(height: 4),
          Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

class Rail extends StatelessWidget {
  final String title;
  final Future<List<Item>> future;
  final void Function(Item) onTap;
  const Rail(this.title, this.future, {super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 18, 14, 8),
          child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 210,
          child: FutureBuilder<List<Item>>(
            future: future,
            builder: (c, s) {
              if (s.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final list = s.data ?? [];
              if (list.isEmpty) return const SizedBox.shrink();
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) => GestureDetector(onTap: () => onTap(list[i]), child: Poster(list[i])),
              );
            },
          ),
        ),
      ],
    );
  }
}

class Msg extends StatelessWidget {
  final Object? error;
  const Msg(this.error, {super.key});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 40),
              const SizedBox(height: 10),
              Text('$error', textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}
