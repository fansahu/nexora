import 'package:flutter/material.dart';
import 'store.dart';
import 'home.dart';
import 'settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Store.init();
  runApp(const Nexora());
}

class Nexora extends StatelessWidget {
  const Nexora({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexora',
      debugShowCheckedModeBanner: false,
      themeMode: Store.theme,
      theme: ThemeData(colorSchemeSeed: const Color(0xFFE50914), brightness: Brightness.light, useMaterial3: true),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFFE50914),
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0B0B0F),
      ),
      home: const Shell(),
    );
  }
}

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _i = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _i, children: const [HomeScreen(), SearchScreen(), AdultScreen(), SettingsScreen()]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _i,
        onDestinationSelected: (v) => setState(() => _i = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.local_fire_department_outlined), selectedIcon: Icon(Icons.local_fire_department), label: '18+'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
