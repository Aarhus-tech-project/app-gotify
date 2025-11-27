import 'package:flutter_application_1/features/pages/search_page.dart';
import 'package:flutter_application_1/features/playlist/playlist_page.dart';
import 'package:go_router/go_router.dart';
import '../features/home/home_page.dart';
import '../features/auth/login_page.dart';
import '../features/auth/register_page.dart';
import '../features/pages/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'route_observer.dart';

Future<bool> checkToken() async {

  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('userToken');
  if (token != null) {
    var response = await http.post(Uri.parse('http://100.116.248.20:3000/user/check-token'),
    headers: <String, String> {"Content-Type": "application/json; charset=UTF-8"},
    body: jsonEncode(<String, String>{"token" : token}));
    if (response.body == 'true') {
      return true;
    }
  }
  return false;
}


class AppRouter {
  static bool _checkedOnStartup = false;

  static final router = GoRouter(
    observers: [routeObserver],
    initialLocation: '/login',
    redirect: (context, state) async {

      if (_checkedOnStartup) {
        return null;
      }

      final loggedIn = await checkToken();

      if (loggedIn) {
        _checkedOnStartup = true;
        return '/';
      }

      if (!loggedIn && state.matchedLocation != '/register') return '/login';

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) {
          final accountCreated = state.extra as bool? ?? false;
          return LoginPage(accountCreated: accountCreated);
        } 
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchPage(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/playlist/:id',
        name: 'playlist',
        builder: (context, state) {
          final id;
          if (state.pathParameters['id'] == 'liked') {
            id = 'liked';
          } else {
            id = int.parse(state.pathParameters['id']!);
          }
          final name = state.uri.queryParameters['name'] ?? 'Playlist';
          return PlaylistPage(playlistId: id, playlistName: name);
        }
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
}
