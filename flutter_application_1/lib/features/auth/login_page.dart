import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../ui/components/primary_button.dart';
import '../../ui/components/text_input.dart';
import '../../ui/layout/page_scaffold.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// decode the username from the JWT token
String? extractUsernameFromToken(String token) {
  try {
    final parts = token.split('.'); // split into header, payload and signature
    if (parts.length != 3) return null; // not a valid JWT

    final payload = parts[1]; // take the middle part
    final normalized = base64Url.normalize(payload); 
    final decoded = utf8.decode(base64Url.decode(normalized)); // decode base64
    final payloadMap = json.decode(decoded) as Map<String, dynamic>; // turn into a JSON Object

    return payloadMap['username'] as String?; // read username
  } catch (e) {
    debugPrint('Error decoding JWT: $e');
    return null;
  }
}

class LoginPage extends StatefulWidget {
  final bool accountCreated;
  const LoginPage({super.key, required this.accountCreated});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();

  bool _busy = false;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => _busy = true);

  try {
    final response = await http.post(
      Uri.parse('http://100.116.248.20:3000/user/login'),
      headers: const {"Content-Type": "application/json; charset=UTF-8"},
      body: jsonEncode({
        "username": _username.text,
        "password": _password.text,
      }),
    );

    setState(() => _busy = false);
    if (!mounted) return;

    if (response.statusCode != 200) {
      showDialog<String>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Login failed'),
          content: const Text('User not found or wrong password.'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.cyanAccent),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      final token = data['token'] as String;
      final picture = data['picture'] as String?;
      final username = extractUsernameFromToken(token);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userToken', token);
      if (username != null) await prefs.setString('username', username);
      if (picture != null) await prefs.setString('picture', picture);

      context.goNamed('home');
    } catch (e) {
      debugPrint('Login error: $e');
      setState(() => _busy = false);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: '',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text(
              'GOTIFY',
              style: TextStyle(
                fontFamily: 'MVBoli',
                fontSize: 25,
                color: Colors.cyanAccent,
              ),
            ),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
            if (widget.accountCreated)
              Text(
                'Account Successfully Created',
                style: TextStyle(
                  fontFamily: 'MVBoli',
                  fontSize: 25,
                  color: Colors.green,
                ),
              ),
            TextInput(
              label: 'Username',
              controller: _username,
              keyboardType: TextInputType.text,
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.015),
            TextInput(
              label: 'Password',
              controller: _password,
              obscure: true,
              validator: (v) =>
                  (v == null || v.length < 5) ? 'Min 5 chars' : null,
            ),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.035),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: 'Sign in',
                    busy: _busy,
                    onPressed: _busy ? null : _submit,
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.01),
            TextButton(
              onPressed: () => context.goNamed('register'),
              child: const Text('No account? Register'),
            ),
          ],
        ),
      ),
    );
  }
}