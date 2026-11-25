import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'search.dart';
import 'settings.dart';
import 'adult.dart';
import 'webseries.dart'; // Naya import

void main() => runApp(const NexoraApp());

class NexoraApp extends StatefulWidget {
  const NexoraApp({super.key});
  @override
  State<NexoraApp> createState() => _NexoraAppState();
}

class _NexoraAppState extends State<NexoraApp> {
  bool isAdultMode = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        isAdultMode = prefs.getBool('adult_mode') ?? false;
        isLoading = false;
      });
    });
  }

  void _updateAdultMode(bool val) => setState(() => isAdultMode = val);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator(color: Colors.redAccent))),
      );
    }
    return MaterialApp(
      title: 'Nexora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black, elevation: 0),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1E1E1E),
          selectedItemColor: Colors.redAccent,
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: MainScreen(isAdultMode: isAdultMode, onModeChanged: _updateAdultMode),
    );
  }
}

class MainScreen extends StatefulWidget {
  final bool isAdultMode;
  final Function(bool) onModeChanged;
  const MainScreen({super.key, required this.isAdultMode, required this.onModeChanged});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  void didUpdateWidget(covariant MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isAdultMode && !widget.isAdultMode && _currentIndex == 3) { // Index 3 kyunki ek naya tab add ho raha hai
      setState(() => _currentIndex = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomeScreen(),
      const SearchScreen(),
      const WebSeriesScreen(), // Naya Tab
      if (widget.isAdultMode) const AdultScreen(),
      SettingsScreen(onToggleAdultMode: widget.onModeChanged),
    ];

    final List<BottomNavigationBarItem> navItems = [
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      const BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
      const BottomNavigationBarItem(icon: Icon(Icons.link), label: 'Direct'), // Naya Tab
      if (widget.isAdultMode) const BottomNavigationBarItem(icon: Icon(Icons.local_fire_department), label: '18+'),
      const BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: navItems,
      ),
    );
  }
}
