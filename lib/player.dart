import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class PlayerScreen extends StatefulWidget {
  final String videoUrl;
  const PlayerScreen({super.key, required this.videoUrl});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final WebViewController controller;
  bool _showControls = false;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            controller.runJavaScript('''
              var style = document.createElement('style');
              style.innerHTML = 'video::-webkit-media-controls { display:none !important; }';
              document.head.appendChild(style);
            ''');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.videoUrl));

    if (controller.platform is AndroidWebViewController) {
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            WebViewWidget(controller: controller),
            if (_showControls)
              Positioned(
                bottom: 40,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPlayerBtn(Icons.audiotrack, 'Audio', () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Audio: English / Hindi')));
                      }),
                      _buildPlayerBtn(Icons.subtitles, 'Subs', () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Subs: Off / English / Hindi')));
                      }),
                      _buildPlayerBtn(Icons.hd, 'Quality', () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quality: Auto')));
                      }),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}
