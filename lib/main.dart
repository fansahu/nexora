import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'search.dart';
import 'settings.dart';
import 'adult.dart';
import 'webseries.dart'; 

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
    // Agar 18+ off ho jaye aur user 18+ tab par ho, toh home pe bhej do
    // 18+ tab ka index 3 hai (Home-0, Search-1, Direct-2, 18+-3, Settings-4)
    if (oldWidget.isAdultMode && !widget.isAdultMode && _currentIndex == 3) {
      setState(() => _currentIndex = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomeScreen(),
      const SearchScreen(),
      const WebSeriesScreen(), // Index 2
      if (widget.isAdultMode) const AdultScreen(), // Index 3 (Dynamic)
      SettingsScreen(onToggleAdultMode: widget.onModeChanged), // Index 3 ya 4
    ];

    final List<BottomNavigationBarItem> navItems = [
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      const BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
      const BottomNavigationBarItem(icon: Icon(Icons.link), label: 'Direct'), // Index 2
      if (widget.isAdultMode) const BottomNavigationBarItem(icon: Icon(Icons.local_fire_department), label: '18+'), // Index 3
      const BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'), // Index 3 ya 4
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
