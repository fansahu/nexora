import 'package:flutter/material.dart';
import 'store.dart';
import 'providers.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final _key = TextEditingController(text: Store.tmdbKey);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _key,
            decoration: const InputDecoration(labelText: 'TMDB API key', border: OutlineInputBorder()),
            onChanged: (v) => Store.tmdbKey = v.trim(),
          ),
          const SizedBox(height: 16),
          _row('Region', Store.region, const ['IN', 'US', 'GB', 'AE'], (v) { Store.region = v; setState(() {}); }),
          _row('UI language', Store.uiLang, const ['hi-IN', 'en-US', 'ta-IN', 'te-IN'], (v) { Store.uiLang = v; setState(() {}); }),
          _row('Default audio', Store.audio, const ['hi', 'en', 'te', 'ta'], (v) { Store.audio = v; setState(() {}); }),
          _row('Default subtitle', Store.sub, const ['hi', 'en', 'off'], (v) { Store.sub = v; setState(() {}); }),
          _row('Default quality', Store.quality, const ['auto', '1080', '720', '480'], (v) { Store.quality = v; setState(() {}); }),
          SwitchListTile(
            title: const Text('18+ content'),
            value: Store.adult,
            onChanged: (v) { Store.adult = v; setState(() {}); },
          ),
          SwitchListTile(
            title: const Text('Light theme'),
            value: Store.theme == ThemeMode.light,
            onChanged: (v) { Store.light = v; setState(() {}); },
          ),
          const Divider(height: 32),
          const Text('Servers (band karna ho to off karo)', style: TextStyle(fontWeight: FontWeight.bold)),
          ...Servers.all.map((p) => SwitchListTile(
                dense: true,
                title: Text(p.name),
                value: !Store.disabled.contains(p.name),
                onChanged: (v) {
                  final d = Store.disabled..remove(p.name);
                  if (!v) d.add(p.name);
                  Store.disabled = d;
                  setState(() {});
                },
              )),
          const Divider(height: 32),
          const Text('Metadata by TMDB', textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _row(String label, String value, List<String> opts, void Function(String) onPick) => ListTile(
        title: Text(label),
        trailing: DropdownButton<String>(
          value: opts.contains(value) ? value : opts.first,
          items: opts.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => onPick(v!),
        ),
      );
}
