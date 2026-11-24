import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Store {
  static late SharedPreferences _p;
  static Future<void> init() async => _p = await SharedPreferences.getInstance();

  static const _defKey = String.fromEnvironment('TMDB_KEY');

  static String get tmdbKey => _p.getString('tmdb_key') ?? _defKey;
  static set tmdbKey(String v) => _p.setString('tmdb_key', v);

  static String get region => _p.getString('region') ?? 'IN';
  static set region(String v) => _p.setString('region', v);

  static String get uiLang => _p.getString('ui_lang') ?? 'hi-IN';
  static set uiLang(String v) => _p.setString('ui_lang', v);

  static String get audio => _p.getString('audio') ?? 'hi';
  static set audio(String v) => _p.setString('audio', v);

  static String get sub => _p.getString('sub') ?? 'hi';
  static set sub(String v) => _p.setString('sub', v);

  static String get quality => _p.getString('quality') ?? 'auto';
  static set quality(String v) => _p.setString('quality', v);

  static bool get adult => _p.getBool('adult') ?? true;
  static set adult(bool v) => _p.setBool('adult', v);

  static List<String> get disabled => (_p.getString('disabled') ?? '').split(',').where((e) => e.isNotEmpty).toList();
  static set disabled(List<String> v) => _p.setString('disabled', v.join(','));

  static ThemeMode get theme => _p.getBool('light') ?? false ? ThemeMode.light : ThemeMode.dark;
  static set light(bool v) => _p.setBool('light', v);
}
