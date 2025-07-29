import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'report_form_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  final _auth = FirebaseAuth.instance;

  void _login() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ReportFormScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _register() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ReportFormScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration:
                  const InputDecoration(labelText: 'Email', icon: Icon(Icons.email)),
            ),
            TextField(
              controller: _passwordController,
              decoration:
                  const InputDecoration(labelText: 'Password', icon: Icon(Icons.lock)),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
            ],
            _isLoading
                ? const CircularProgressIndicator()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: _login,
                        child: const Text('Login'),
                      ),
                      ElevatedButton(
                        onPressed: _register,
                        child: const Text('Register'),
                      ),
                    ],
                  )
          ],
        ),
      ),
    );
  }
}
