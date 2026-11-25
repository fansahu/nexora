import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final Function(bool)? onToggleAdultMode;
  const SettingsScreen({super.key, this.onToggleAdultMode});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _tmdbController = TextEditingController();
  bool _isAdultMode = false;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _tmdbController.text = prefs.getString('tmdb_key') ?? '';
        _isAdultMode = prefs.getBool('adult_mode') ?? false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _tmdbController,
            obscureText: true, 
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(labelText: 'TMDB API Key', border: OutlineInputBorder()),
            onChanged: (val) async {
              final prefs = await SharedPreferences.getInstance();
              prefs.setString('tmdb_key', val);
            },
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            title: const Text('18+ Content (Hardcore Only)'),
            activeColor: Colors.redAccent,
            value: _isAdultMode,
            onChanged: (val) async {
              final prefs = await SharedPreferences.getInstance();
              prefs.setBool('adult_mode', val);
              setState(() => _isAdultMode = val);
              if (widget.onToggleAdultMode != null) widget.onToggleAdultMode!(val);
            },
          ),
          const Divider(height: 40),
          const Text('Working Servers', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          const SwitchListTile(title: Text('VidLink'), value: true, onChanged: null),
          const SwitchListTile(title: Text('Videasy'), value: true, onChanged: null),
          const SwitchListTile(title: Text('EmbedWave'), value: true, onChanged: null),
          const SizedBox(height: 60),
          const Center(child: Text('Made by insane~Hulk', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))),
          const Center(child: Text('NEXORA', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, letterSpacing: 4))),
        ],
      ),
    );
  }
}
