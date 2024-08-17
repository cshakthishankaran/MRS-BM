import 'package:company_studio/components/my_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:company_studio/components/my_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  final void Function()? onTap;
  const LoginScreen({super.key, required this.onTap});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isPasswordVisible = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  void _loadSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _usernameController.text = prefs.getString('username') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
      _rememberMe = prefs.getBool('rememberMe') ?? false;
    });
  }

  void _login() async {
    setState(() {
      _errorMessage = '';
    });

    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username == 'venkadesh@mrs.com' && password == 'Venky@12345') {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        prefs.setString('username', username);
        prefs.setString('password', password);
        prefs.setBool('rememberMe', _rememberMe);
        prefs.setBool('clickedLoggedOut', false);
      } else {
        prefs.remove('username');
        prefs.remove('password');
        prefs.remove('rememberMe');
        prefs.setBool('clickedLoggedOut', false);
      }
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() {
        _errorMessage = 'Invalid username or password';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Stack(
                      children: [
                        Image.asset(
                          'asset/images/mrs_logo-3-nb.png',
                          width: 100,
                        ),
                        Positioned(
                          top: -3,
                          right: 10,
                          child: Image.asset(
                            'asset/images/login_image.png',
                            width: 50,
                            height: 50,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    "Welcome",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                  const SizedBox(height: 25),
                  MyTextField(
                    controller: _usernameController,
                    obscureText: false,
                    hintText: 'Username',
                    textCapitalization: TextCapitalization.none,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp('.*'))],
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 25),
                  MyTextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    hintText: 'Password',
                    textCapitalization: TextCapitalization.none,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp('.*'))],
                    keyboardType: TextInputType.visiblePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 25.0),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (bool? value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                      ),
                      const Text('Remember Me'),
                    ],
                  ),
                  MyButton(
                    onTap: _login,
                    text: "Sign In",
                    padding: const EdgeInsets.all(30),
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Not a member? ",
                        style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          "Register Now",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '\u00A9 ${DateTime.now().year} All Rights Reserved',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
