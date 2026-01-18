import 'package:flutter/material.dart';
import 'package:export_trix/data/services/api_service.dart';
import 'package:export_trix/core/widgets/responsive_layout.dart';
import 'dart:ui'; // For BackdropFilter

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

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
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await ApiService.forgotPassword(_emailController.text);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reset link sent! Check your email.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
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

  // --- Desktop Layout ---
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left Side: Branding
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
                      child: const Icon(Icons.lock_reset,
                          size: 120, color: Colors.white),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'ACCOUNT RECOVERY',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Securely restore access to your account.',
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

        // Right Side: Form
        Expanded(
          flex: 4,
          child: Container(
            color: Colors.white,
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 450),
                padding: const EdgeInsets.all(48),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter your email address and we will send you a link to reset your password.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 48),
                      _buildFormFields(isDesktop: true),
                      const SizedBox(height: 32),
                      _buildResetButton(),
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

  // --- Mobile Layout ---
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
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
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
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new,
                              color: Colors.white),
                        ),
                        const Spacer(),
                        const Text(
                          'Reset Password',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(flex: 2),
                      ],
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
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Icon(Icons.lock_reset,
                                    size: 60, color: Color(0xFF1E3A8A)),
                                const SizedBox(height: 16),
                                Text(
                                  'Forgot your password?',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Enter your email address and we will send you a link to reset your password.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 32),
                                _buildFormFields(isDesktop: false),
                                const SizedBox(height: 24),
                                _buildResetButton(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
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
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email Address',
        prefixIcon: const Icon(Icons.email_outlined),
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
      ),
      validator: (value) => value!.isEmpty ? 'Please enter your email' : null,
    );
  }

  Widget _buildResetButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _resetPassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Send Reset Link',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
