import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class PlayerScreen extends StatefulWidget {
  final int id;
  final String type;
  final int? season;
  final int? episode;

  const PlayerScreen({super.key, required this.id, required this.type, this.season, this.episode});
  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final WebViewController controller;
  String currentServer = 'VidLink';
  bool _showControls = false;

  final Map<String, String> servers = {
    'VidLink': 'https://vidlink.pro',
    'Videasy': 'https://player.videasy.net',
    'EmbedWave': 'https://embed.su/embed',
    'Vidsrc.to': 'https://vidsrc.to/embed',
    '2Embed': 'https://www.2embed.cc/embed',
  };

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    String url = '';
    final base = servers[currentServer]!;
    
    // Fallbacks if season/episode are null
    final s = widget.season ?? 1;
    final e = widget.episode ?? 1;

    if (widget.type == 'movie') {
      if (currentServer == '2Embed') url = "$base/${widget.id}";
      else url = "$base/movie/${widget.id}";
    } else {
      // TV Series URL formatting
      if (currentServer == '2Embed') {
        url = "https://www.2embed.cc/embedtv/${widget.id}&s=$s&e=$e";
      } else if (currentServer == 'Vidsrc.to') {
        url = "$base/tv/${widget.id}/$s/$e";
      } else {
        url = "$base/tv/${widget.id}/$s/$e";
      }
    }

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (u) {
            controller.runJavaScript('''
              var style = document.createElement('style');
              style.innerHTML = 'video::-webkit-media-controls { display:none !important; }';
              document.head.appendChild(style);
            ''');
          },
        ),
      )
      ..loadRequest(Uri.parse(url));

    if (controller.platform is AndroidWebViewController) {
      (controller.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
    }
  }

  void _changeServer(String server) {
    setState(() {
      currentServer = server;
      _initController();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => setState(() => _showControls = !_showControls),
        child: Stack(
          children: [
            WebViewWidget(controller: controller),
            if (_showControls)
              Positioned(
                bottom: 30, left: 20, right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.9), 
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.dns, color: Colors.redAccent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: currentServer,
                            isExpanded: true,
                            dropdownColor: Colors.black,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            items: servers.keys.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                            onChanged: (v) => _changeServer(v!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
