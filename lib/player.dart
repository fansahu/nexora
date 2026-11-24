import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'providers.dart';
import 'store.dart';

class PlayerScreen extends StatefulWidget {
  final int id;
  final String type;
  final String title;
  final int? season;
  final int? episode;
  const PlayerScreen({
    super.key,
    required this.id,
    required this.type,
    required this.title,
    this.season,
    this.episode,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  WebViewController? _c;
  int _i = 0;
  bool _loading = true;
  bool _stuck = false;
  List<Provider> _servers = [];

  bool get _tv => widget.type == 'tv';

  @override
  void initState() {
    super.initState();
    _servers = Servers.ordered(adultFirst: Store.adult);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _load();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  String _urlOf(Provider p) => p.build(widget.id, widget.season ?? 1, widget.episode ?? 1, _tv);

  void _load() {
    if (_servers.isEmpty || _i >= _servers.length) return;
    final url = _urlOf(_servers[_i]);
    setState(() {
      _loading = true;
      _stuck = false;
    });

    _c = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setMediaPlaybackRequiresUserGesture(false)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) async {
          if (!mounted) return;
          setState(() => _loading = false);
          await Future.delayed(const Duration(seconds: 7));
          if (!mounted || _c == null) return;
          try {
            final r = await _c!.runJavaScriptReturningResult(
                "document.querySelectorAll('video').length");
            if (r.toString() == '0' && mounted) setState(() => _stuck = true);
          } catch (_) {}
        },
        onWebResourceError: (e) {
          if (e.isForMainFrame ?? true) _next();
        },
      ))
      ..loadRequest(Uri.parse(url));
  }

  void _next() {
    if (!mounted) return;
    if (_i + 1 >= _servers.length) {
      setState(() {
        _loading = false;
        _stuck = true;
      });
      return;
    }
    setState(() => _i++);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final p = _servers.isEmpty ? null : _servers[_i];
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            if (_c != null)
              WebViewWidget(controller: _c!)
            else
              const Center(child: CircularProgressIndicator()),
            if (_loading) const Center(child: CircularProgressIndicator()),
            if (_stuck)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  color: Colors.black87,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text('Server respond nahi kar raha'),
                    const SizedBox(height: 8),
                    FilledButton(onPressed: _next, child: const Text('Agla server')),
                  ]),
                ),
              ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
                    Expanded(child: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Text('${_i + 1}/${_servers.length}', style: const TextStyle(fontSize: 11)),
                    IconButton(tooltip: 'Agla server', icon: const Icon(Icons.switch_video), onPressed: _next),
                    IconButton(
                      tooltip: 'Browser me kholo',
                      icon: const Icon(Icons.open_in_new),
                      onPressed: p == null
                          ? null
                          : () => launchUrl(Uri.parse(_urlOf(p)), mode: LaunchMode.externalApplication),
                    ),
                    PopupMenuButton<String>(
                      tooltip: 'Server',
                      icon: const Icon(Icons.dns),
                      onSelected: (n) {
                        final idx = Servers.indexOf(_servers, n);
                        if (idx < 0) return;
                        _i = idx;
                        _load();
                      },
                      itemBuilder: (_) => _servers
                          .map((e) => PopupMenuItem(value: e.name, child: Text(e.name)))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    _menu('Audio', Store.audio, const {
                      'hi': 'Hindi',
                      'en': 'English',
                      'te': 'Telugu',
                      'ta': 'Tamil',
                      'ml': 'Malayalam',
                      'kn': 'Kannada',
                      'pa': 'Punjabi',
                      'bn': 'Bengali',
                      'mr': 'Marathi',
                    }, (v) {
                      Store.audio = v;
                      _load();
                    }),
                    _menu('Subtitle', Store.sub, const {'off': 'Off', 'hi': 'Hindi', 'en': 'English'}, (v) {
                      Store.sub = v;
                      _load();
                    }),
                    _menu('Quality', Store.quality, const {
                      'auto': 'Auto',
                      '1080': '1080p',
                      '720': '720p',
                      '480': '480p',
                      '360': '360p',
                    }, (v) {
                      Store.quality = v;
                      _load();
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

  Widget _menu(String label, String value, Map<String, String> opts, void Function(String) onPick) {
    return Expanded(
      child: PopupMenuButton<String>(
        onSelected: onPick,
        itemBuilder: (_) => opts.entries.map((e) => PopupMenuItem(value: e.key, child: Text(e.value))).toList(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Text('$label: ${opts[value] ?? value}', style: const TextStyle(fontSize: 12)),
        ),
      ),
    );
  }
}
