import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'extractor.dart';

class WebSeriesScreen extends StatefulWidget {
  const WebSeriesScreen({super.key});
  @override
  State<WebSeriesScreen> createState() => _WebSeriesScreenState();
}

class _WebSeriesScreenState extends State<WebSeriesScreen> {
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;

  void _loadVideo() async {
    String inputUrl = _urlController.text.trim();
    if (inputUrl.isEmpty) return;
    
    // Agar URL nahi hai, toh google search karo
    if (!inputUrl.startsWith('http')) {
      inputUrl = 'https://www.google.com/search?q=${Uri.encodeComponent(inputUrl)}+watch+online';
    }

    setState(() => _isLoading = true);
    
    // Video link extract karne ki koshish karo
    String? directLink = await Extractor.getVideoLink(inputUrl);
    
    setState(() => _isLoading = false);

    if (directLink != null) {
      // Agar link mil gaya, toh player kholo
      Navigator.push(context, MaterialPageRoute(builder: (_) => DirectPlayer(url: directLink!)));
    } else {
      // Agar direct link nahi mila, toh WebView me open karo taaki user manually dekh sake
      Navigator.push(context, MaterialPageRoute(builder: (_) => DirectPlayer(url: inputUrl)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Web Series & Custom Links', style: TextStyle(color: Colors.redAccent))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Yahan kisi bhi website ka link daalo (Ullu, AltBalaji, piracy sites). App usko play karne ki koshish karega.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _urlController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Paste URL or Search Name...',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.redAccent),
                  onPressed: _loadVideo,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoading) const CircularProgressIndicator(color: Colors.redAccent),
          ],
        ),
      ),
    );
  }
}

class DirectPlayer extends StatefulWidget {
  final String url;
  const DirectPlayer({super.key, required this.url});
  @override
  State<DirectPlayer> createState() => _DirectPlayerState();
}

class _DirectPlayerState extends State<DirectPlayer> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Player')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
