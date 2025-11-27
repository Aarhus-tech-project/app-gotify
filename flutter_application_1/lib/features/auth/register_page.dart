import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../ui/components/primary_button.dart';
import '../../ui/components/text_input.dart';
import '../../ui/layout/page_scaffold.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);

    var response = await http.post(Uri.parse('http://100.116.248.20:3000/user/register'),
    headers: <String, String> {"Content-Type": "application/json; charset=UTF-8"},
    body: jsonEncode(<String, String>{"username":_username.text, "password":_password.text}));

    setState(() => _busy = false);
    if (!mounted) return;

    if (response.body == "USERNAME_NOT_AVAILABLE") {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Username Unavailable'),
          content: const Text('This username has already been taken'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.cyanAccent)),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.pop(context, 'OK'), child: const Text('OK')),
          ],
        ),
      );

    } else if (response.body == 'true') {
      context.goNamed('login', extra: true);
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
            Text('GOTIFY', style: TextStyle(fontFamily: 'MVBoli', fontSize: 25, color: Colors.cyanAccent),),
            Padding(padding: EdgeInsetsGeometry.all(MediaQuery.sizeOf(context).height * 0.01)),
            TextInput(
              label: 'Username',
              controller: _username,
              keyboardType: TextInputType.text,
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            Padding(padding: EdgeInsetsGeometry.all(MediaQuery.sizeOf(context).height * 0.01)),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.012),
            TextInput(
              label: 'Password',
              controller: _password,
              obscure: true,
              validator: (v) =>
                  (v == null || v.length < 6) ? 'Min 6 chars' : null,
            ),
            Padding(padding: EdgeInsetsGeometry.all(MediaQuery.sizeOf(context).height * 0.01)),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.012),
            TextInput(
              label: 'Confirm Password',
              controller: _confirm,
              obscure: true,
              validator: (v) => (v != _password.text) ? 'Does not match' : null,
            ),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.035),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: 'Create account',
                    busy: _busy,
                    onPressed: _busy ? null : _submit,
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.01),
            TextButton(
              onPressed: () => context.goNamed('login'),
              child: const Text('Already have an account? Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}