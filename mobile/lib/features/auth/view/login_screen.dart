import 'package:flutter/material.dart';
import 'package:export_trix/core/api/api_client.dart';
import 'package:export_trix/core/api/token_storage.dart';
import 'package:export_trix/features/auth/view/register_screen.dart';
import 'package:export_trix/features/auth/view/forgot_password_screen.dart';
import 'package:export_trix/features/products/view/product_list_screen.dart';
import 'package:export_trix/core/widgets/responsive_layout.dart';
import 'package:export_trix/core/utils/logger.dart';
import 'dart:ui'; // For BackdropFilter

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      AppLogger.debug('Attempting login with email: ${_emailController.text}');
      final response = await ApiClient.instance.dio.post(
        '/auth/login',
        data: {
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        },
      );

      AppLogger.debug('Login response data: ${response.data}');

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final token = data['token'];
        final role = data['user']['role'];

        await TokenStorage.setToken(token);
        await TokenStorage.setRole(role);

        if (!mounted) return;
        // The new instruction implies a single dashboard route after successful login.
        // The role-based navigation should ideally be handled within the dashboard or a routing service.
        // For now, we follow the instruction to navigate to '/dashboard'.
        await Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        if (!mounted) return;
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProductListScreen()),
        );
      }
    } catch (e) {
      AppLogger.error('Login error', e);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }

  // --- Desktop Layout (Split Screen) ---
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left Side: Branding (Gradient + Logo)
        Expanded(
          flex: 5,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F172A), // Slate 900
                  Color(0xFF1E3A8A), // Indigo 800
                  Color(0xFF3B82F6), // Blue 500
                ],
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Decorative circles
                Positioned(
                  top: -100,
                  left: -100,
                  child: Container(
                    width: 500,
                    height: 500,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                          blurRadius: 150,
                          spreadRadius: 50,
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: const Icon(Icons.public,
                          size: 120, color: Colors.white),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'EXPORT TRIX',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Global Export Management System',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Right Side: Login Form (White Background)
        Expanded(
          flex: 4,
          child: Container(
            color: Colors.white,
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 450),
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please enter your details to sign in.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 48),
                      _buildFormFields(isDesktop: true),
                      const SizedBox(height: 32),
                      _buildLoginButton(),
                      const SizedBox(height: 32),
                      _buildRegisterLink(color: Colors.grey[800]!),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- Mobile Layout (Gradient + Glassmorphism) ---
  Widget _buildMobileLayout() {
    return Stack(
      children: [
        // 1. Gradient Background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0F172A), // Slate 900
                Color(0xFF1E3A8A), // Indigo 800
                Color(0xFF3B82F6), // Blue 500
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),

        // 2. Deco Shapes
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                  blurRadius: 100,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          right: -50,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF818CF8).withValues(alpha: 0.2),
                  blurRadius: 80,
                ),
              ],
            ),
          ),
        ),

        // 3. Content
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: const Icon(
                        Icons.public,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'EXPORT TRIX',
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Glass Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 400),
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.5)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 25,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildFormFields(isDesktop: false),
                              const SizedBox(height: 32),
                              _buildLoginButton(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildRegisterLink(color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- Shared Widgets ---

  Widget _buildFormFields({required bool isDesktop}) {
    return Column(
      children: [
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(fontWeight: FontWeight.w500),
          decoration: _getInputDecoration(
              'Email Address', Icons.email_outlined, isDesktop),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          style: const TextStyle(fontWeight: FontWeight.w500),
          decoration:
              _getInputDecoration('Password', Icons.lock_outlined, isDesktop)
                  .copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
        ),

        // Forgot Password Link
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ForgotPasswordScreen(),
                ),
              );
            },
            child: const Text(
              'Forgot Password?',
              style: TextStyle(
                  color: Color(0xFF3B82F6), fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _getInputDecoration(
      String label, IconData icon, bool isDesktop) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
          shadowColor: const Color(0xFF1E3A8A).withValues(alpha: 0.5),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Login',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
      ),
    );
  }

  Widget _buildRegisterLink({required Color color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "New here?",
          style: TextStyle(
              color: color == Colors.white ? Colors.white70 : Colors.grey[600],
              fontSize: 16),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterScreen()),
            );
          },
          child: Text(
            "Create Account",
            style: TextStyle(
              color: color == Colors.white
                  ? Colors.white
                  : const Color(0xFF1E3A8A),
              fontWeight: FontWeight.bold,
              fontSize: 16,
              decoration: TextDecoration.underline,
              decorationColor: color == Colors.white
                  ? Colors.white
                  : const Color(0xFF1E3A8A),
            ),
          ),
        ),
      ],
    );
  }
}
