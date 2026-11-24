import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _tmdbController = TextEditingController();
  bool _isAdultMode = false;
  bool _isObscure = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _tmdbController.text = prefs.getString('tmdb_key') ?? '';
      _isAdultMode = prefs.getBool('adult_mode') ?? false;
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
            obscureText: _isObscure,
            enableSuggestions: false,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: 'TMDB API Key',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _isObscure = !_isObscure),
              ),
            ),
            onChanged: (val) async {
              final prefs = await SharedPreferences.getInstance();
              prefs.setString('tmdb_key', val);
            },
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            title: const Text('18+ Content'),
            value: _isAdultMode,
            onChanged: (val) async {
              final prefs = await SharedPreferences.getInstance();
              prefs.setBool('adult_mode', val);
              setState(() => _isAdultMode = val);
              // App restart ya rebuild force karne ke liye main.dart wala build trigger hoga
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const NexoraApp()),
                (route) => false,
              );
            },
          ),
          const Divider(),
          const Text('Servers (Only working)', style: TextStyle(color: Colors.grey)),
          SwitchListTile(title: const Text('VidLink'), value: true, onChanged: (v) {}),
          SwitchListTile(title: const Text('Videasy'), value: true, onChanged: (v) {}),
          
          const SizedBox(height: 40),
          
          // CREDIT YAHAN HAI
          const Center(
            child: Column(
              children: [
                Text('NEXORA', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, letterSpacing: 3)),
                SizedBox(height: 5),
                Text('Made by insane ~ hulk', style: TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
