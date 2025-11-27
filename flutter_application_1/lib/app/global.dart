import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Globals {
  static bool playerIsOpen = false;
  static List<Map<String, dynamic>> playlist = [];
  static List<String> recentSearches = [];

  static Map<String, int> likeStatus = {};

  static Future<void> saveRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recentSearches', Globals.recentSearches);
  }

  static Future<void> addRecentSearches(String? songData) async {
    if (songData!.isEmpty) return;
    Globals.recentSearches.remove(songData);
    Globals.recentSearches.insert(0, songData);
    if (Globals.recentSearches.length > 15) {
      Globals.recentSearches = Globals.recentSearches.sublist(0, 15);
    }
    await saveRecentSearches();
  }

  static Future<void> likeUnlike(String? hash) async {
    if (hash == null) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken');
    if (token == null) throw Exception('No auth token');

    await http.post(
      Uri.parse('http://100.116.248.20/api/music/like/$hash'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (Globals.likeStatus.containsKey(hash)) {
      Globals.likeStatus[hash] = Globals.likeStatus[hash] == 1 ? 0 : 1;
    } else {
      Globals.likeStatus[hash] = 1;
    }

    final index = Globals.recentSearches.indexWhere((item) {
      final data = jsonDecode(item);
      return data['hash'] == hash;
    });

    if (index != -1) {
      final data = jsonDecode(Globals.recentSearches[index]);
      data['liked'] = data['liked'] == 1 ? 0 : 1;
      Globals.recentSearches[index] = jsonEncode(data);
      await Globals.saveRecentSearches();
    }
  }
}