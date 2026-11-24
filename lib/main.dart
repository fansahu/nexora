import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'search.dart'; // assuming tumhare paas ye hai
import 'settings.dart';
import 'adult_zone.dart'; // ek nayi file banani padegi 18+ ke liye

void main() {
  runApp(const NexoraApp());
}

class NexoraApp extends StatefulWidget {
  const NexoraApp({super.key});

  @override
  State<NexoraApp> createState() => _NexoraAppState();
}

class _NexoraAppState extends State<NexoraApp> {
  bool isAdultMode = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => isAdultMode = prefs.getBool('adult_mode') ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1E1E1E),
          selectedItemColor: Colors.redAccent,
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: MainScreen(isAdultMode: isAdultMode),
    );
  }
}

class MainScreen extends StatefulWidget {
  final bool isAdultMode;
  const MainScreen({super.key, required this.isAdultMode});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      const HomeScreen(),
      const Center(child: Text('Search Screen')), // Yahan apna Search dalna
      if (widget.isAdultMode) const AdultZoneScreen(), // Naya 18+ page
      const SettingsScreen(),
    ];

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          if (widget.isAdultMode)
            const BottomNavigationBarItem(icon: Icon(Icons.local_fire_department), label: '18+'),
          const BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
