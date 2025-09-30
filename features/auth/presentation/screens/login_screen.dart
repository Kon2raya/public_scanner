import 'dart:convert';

import 'package:aai_scanner_epson/core/config/theme/color_constant.dart';
import 'package:aai_scanner_epson/core/routes/route_manager.dart';
import 'package:aai_scanner_epson/core/services/connectivity_service.dart';
import 'package:aai_scanner_epson/core/services/session_manager.dart';
import 'package:aai_scanner_epson/core/utils/dialog_utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final userNameCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool _isLoading = false;
  bool rememberMe = false;
  bool obscurePassword = true;
  final authService = AuthService();

  // Cache SharedPreferences instance
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _initializeAndLoadCredentials();
  }

  Future<void> _initializeAndLoadCredentials() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _loadSavedCredentials();
    } catch (e) {
      // Handle error silently
    }
  }

  void _loadSavedCredentials() {
    if (_prefs == null) return;

    final savedUsername = _prefs!.getString('savedUsername');
    final savedPassword = _prefs!.getString('savedPassword');
    final savedRemember = _prefs!.getBool('rememberMe') ?? false;

    if (savedRemember && savedUsername != null && savedPassword != null) {
      userNameCtrl.text = savedUsername;
      passCtrl.text = savedPassword;
      setState(() => rememberMe = true);
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Check connectivity with timeout
      final connectivityService = ConnectivityService();
      final connected = await connectivityService.isConnected().timeout(
        const Duration(seconds: 3),
      );

      if (!connected) {
        if (!mounted) return;
        await _showDialog(
          'No Internet Connection',
          'Please check your network settings and try again.',
          warning: true,
          icon: Icons.wifi_off,
        );
        setState(() => _isLoading = false);
        return;
      }

      final data = {
        'username': userNameCtrl.text.trim(),
        'password': passCtrl.text.trim(),
        'system': 'wms',
        'device_name': 'mobile',
      };

      final response = await authService.postData(data, 'token');

      if (!mounted) return;
      setState(() => _isLoading = false);

      final result = json.decode(response.body);

      if (result['status'] == true) {
        await _handleSuccessfulLogin(result);
      } else {
        await _showDialog(
          'Login Failed',
          'Invalid username or password. Please try again.',
          success: false,
          icon: Icons.dangerous,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      await _showDialog(
        'Error',
        'An error occurred. Please try again.',
        success: false,
        icon: Icons.error,
      );
    }
  }

  Future<void> _handleSuccessfulLogin(Map<String, dynamic> result) async {
    try {
      final res = result['data'];
      _prefs ??= await SharedPreferences.getInstance();

      final user = {
        'name': "${res['firstname']} ${res['lastname']}",
        'email': res['email'],
        'id': res['id'],
      };

      // Use Future.wait for parallel operations
      final futures = <Future>[
        _prefs!.setString('token', result['token'] ?? ''),
        _prefs!.setBool('isLoggedIn', true),
        _prefs!.setInt('id', res['id']),
        _prefs!.setString('user', json.encode(user)),
      ];

      // Handle remember me preferences
      if (rememberMe) {
        futures.addAll([
          _prefs!.setString('savedUsername', userNameCtrl.text.trim()),
          _prefs!.setString('savedPassword', passCtrl.text.trim()),
          _prefs!.setBool('rememberMe', true),
        ]);
      } else {
        futures.addAll([
          _prefs!.remove('savedUsername'),
          _prefs!.remove('savedPassword'),
          _prefs!.setBool('rememberMe', false),
        ]);
      }

      await Future.wait(futures);

      // Update SessionManager cache
      await SessionManager.setLoggedIn(result['token'] ?? '');

      if (!mounted) return;

      // Show success dialog
      await _showDialog(
        'Login Successful',
        'Welcome, ${res['firstname']} ${res['lastname']}!',
        success: true,
        icon: Icons.check_circle,
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(RouteManager.inboundScanEnty);
    } catch (e) {
      if (!mounted) return;
      await _showDialog(
        'Error',
        'Login successful but failed to save session. Please try again.',
        success: false,
        icon: Icons.error,
      );
    }
  }

  Future<bool?> _showDialog(
    String title,
    String message, {
    bool warning = false,
    bool success = true,
    required IconData icon,
  }) async {
    return await DialogUtils.showCustomDialog(
      context: context,
      title: title,
      message: message,
      warning: warning,
      success: success,
      icon: icon,
      actions: [
        DialogAction(
          label: 'OK',
          returnValue: true,
          color: AppColors.primaryRed,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Use RepaintBoundary for background image
        RepaintBoundary(
          child: Image.asset(
            "assets/background/wh6.png",
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            // Add caching hints
            cacheWidth: MediaQuery.of(context).size.width.round(),
            cacheHeight: MediaQuery.of(context).size.height.round(),
          ),
        ),
        _buildLoginForm(),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RepaintBoundary(
                            child: Image.asset(
                              "assets/logo/aai_logo_new.png",
                              height: 40,
                              cacheWidth: 80,
                              cacheHeight: 30,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildUsernameField(),
                          const SizedBox(height: 15),
                          _buildPasswordField(),
                          _buildRememberMeRow(),
                          _buildLoginButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUsernameField() {
    return TextFormField(
      controller: userNameCtrl,
      decoration: InputDecoration(
        labelText: "Username",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      validator: (value) => value == null || value.trim().isEmpty
          ? 'Username is required.'
          : null,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: passCtrl,
      obscureText: obscurePassword,
      decoration: InputDecoration(
        labelText: "Password",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
        filled: true,
        fillColor: Colors.grey[100],
        suffixIcon: IconButton(
          icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => obscurePassword = !obscurePassword),
        ),
      ),
      validator: (value) => value == null || value.trim().isEmpty
          ? 'Password is required.'
          : null,
    );
  }

  Widget _buildRememberMeRow() {
    return Row(
      children: [
        Checkbox(
          value: rememberMe,
          onChanged: (value) => setState(() => rememberMe = value ?? false),
          checkColor: Colors.white,
          activeColor: AppColors.primaryRed,
        ),
        const Text("Remember Me"),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: _isLoading ? null : _handleLogin,
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text("Login"),
      ),
    );
  }

  @override
  void dispose() {
    userNameCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }
}
