import 'package:http/http.dart' as http;
import 'dart:convert';

class Extractor {
  // Yeh function kisi bhi webpage ka HTML fetch karke usme se m3u8 ya mp4 link nikalne ki koshish karega
  static Future<String?> getVideoLink(String url) async {
    try {
      final res = await http.get(Uri.parse(url), headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
      }).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final html = res.body;
        
        // Regex to find .m3u8 or .mp4 links
        final m3u8Regex = RegExp(r'(https?:\/\/[^\s"\'<>]+\.m3u8[^\s"\'<>]*)');
        final mp4Regex = RegExp(r'(https?:\/\/[^\s"\'<>]+\.mp4[^\s"\'<>]*)');
        
        final m3u8Match = m3u8Regex.firstMatch(html);
        if (m3u8Match != null) return m3u8Match.group(0);
        
        final mp4Match = mp4Regex.firstMatch(html);
        if (mp4Match != null) return mp4Match.group(0);

        // Agar direct link nahi mila, toh iframe src nikalne ki koshish karo
        final iframeRegex = RegExp(r'<iframe[^>]+src="([^"]+)"');
        final iframeMatch = iframeRegex.firstMatch(html);
        if (iframeMatch != null) {
          // Recursively call for iframe src
          return await getVideoLink(iframeMatch.group(1)!);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
                                                                 }
