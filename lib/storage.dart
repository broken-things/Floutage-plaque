import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kCustomTextKey = 'customText';
const String _kBgColorKey = 'plate_bg_color';
const String _kTextColorKey = 'plate_text_color';

// Sauvegarde du texte
Future<void> saveCustomText(String text) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_kCustomTextKey, text);
}

// Chargement du texte
Future<String?> loadCustomText() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_kCustomTextKey);
}

// Sauvegarde des couleurs
Future<void> savePlateColors(Color bgColor, Color textColor) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_kBgColorKey, bgColor.value);
  await prefs.setInt(_kTextColorKey, textColor.value);
}

// Chargement des couleurs
Future<Map<String, Color>> loadPlateColors() async {
  final prefs = await SharedPreferences.getInstance();
  final bg = prefs.getInt(_kBgColorKey) ?? Colors.black.value;
  final text = prefs.getInt(_kTextColorKey) ?? Colors.white.value;
  return {'bg': Color(bg), 'text': Color(text)};
}
