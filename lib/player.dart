import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class PlayerScreen extends StatefulWidget {
  final int id;
  final String type;
  const PlayerScreen({super.key, required this.id, required this.type});
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
  };

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    String baseUrl = servers[currentServer]!;
    String url = "$baseUrl/${widget.type}/${widget.id}";

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
                bottom: 40, left: 20, right: 20,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.9), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DropdownButton<String>(
                        value: currentServer,
                        dropdownColor: Colors.black,
                        style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                        items: servers.keys.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (v) => _changeServer(v!),
                      ),
                      const Text('Audio/Subs: Hardware keys', style: TextStyle(color: Colors.grey, fontSize: 12)),
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
