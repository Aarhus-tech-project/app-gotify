import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileIcon extends StatefulWidget {
  const ProfileIcon({super.key});

  @override
  State<ProfileIcon> createState() => _ProfileIconState();
}

class _ProfileIconState extends State<ProfileIcon> {
  String? _profilePictureUrl;
  static const String baseUrl = 'http://100.116.248.20/profiles/';

  @override
  void initState() {
    super.initState();
    _loadProfilePicture();
  }

  Future<void> _loadProfilePicture() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profilePictureUrl = prefs.getString('picture');
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.goNamed('profile'),
      child: CircleAvatar(
        radius: 18,
        backgroundColor: Colors.grey,
        backgroundImage: _profilePictureUrl != null
            ? NetworkImage('$baseUrl${_profilePictureUrl!}')
            : null,
        child: _profilePictureUrl == null
            ? const Icon(Icons.person, color: Colors.white)
            : null,
      ),
    );
  }
}