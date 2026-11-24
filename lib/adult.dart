import 'package:flutter/material.dart';

class AdultScreen extends StatelessWidget {
  const AdultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('18+ Zone', style: TextStyle(color: Colors.redAccent))),
      body: const Center(
        child: Text('Hardcore & Adult Content Here', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
