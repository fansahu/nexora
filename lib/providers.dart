class Provider {
  final String name;
  final bool adult;
  final String Function(int id, int season, int episode, bool tv) build;
  const Provider(this.name, this.build, {this.adult = false});
}

String _q(String url) {
  final a = Store.audio;
  final s = Store.sub;
  final q = Store.quality;
  return '$url?audio=$a&sub=$s&quality=$q';
}
