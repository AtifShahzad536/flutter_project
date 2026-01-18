import 'package:flutter/material.dart';
import 'package:export_trix/core/api/api_client.dart';
import 'package:export_trix/core/widgets/responsive_layout.dart';
import 'dart:ui'; // For BackdropFilter
import 'package:export_trix/core/utils/logger.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'user'; // Default role
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        AppLogger.debug(
            'Attempting to register user: ${_nameController.text.trim()}');
        final response = await ApiClient.instance.dio.post(
          '/auth/register',
          data: {
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'password': _passwordController.text,
            'role': _selectedRole,
          },
        );

        AppLogger.debug('Registration response: ${response.data}');

        if (response.data['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      response.data['message'] ?? 'Registration successful!')),
            );
            Navigator.pop(context); // Go back to login
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(response.data['message'] ?? 'Registration failed'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
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
                  right: -100,
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
                      'JOIN THE FUTURE',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Create your free account today.',
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

        // Right Side: Register Form
        Expanded(
          flex: 4,
          child: Container(
            color: Colors.white,
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  padding: const EdgeInsets.all(48),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[900],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please fill in the form below.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 40),
                        _buildFormFields(isDesktop: true),
                        const SizedBox(height: 32),
                        _buildRegisterButton(),
                        const SizedBox(height: 24),
                        _buildLoginLink(color: Colors.grey[800]!),
                      ],
                    ),
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
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                  blurRadius: 100,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          left: -50,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF818CF8).withValues(alpha: 0.15),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new,
                              color: Colors.white),
                        ),
                        const Spacer(),
                        const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const Spacer(flex: 2),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Join the global marketplace today',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Glass Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 450),
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
                                _buildFormFields(isDesktop: false),
                                const SizedBox(height: 32),
                                _buildRegisterButton(),
                                const SizedBox(height: 16),
                                _buildLoginLink(
                                    color: Colors
                                        .grey[800]!), // Text is on white card
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Full Name
        TextFormField(
          controller: _nameController,
          decoration:
              _getInputDecoration('Full Name', Icons.person_outline, isDesktop),
          validator: (value) =>
              value!.isEmpty ? 'Please enter your name' : null,
        ),
        const SizedBox(height: 16),

        // Email
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _getInputDecoration(
              'Email Address', Icons.email_outlined, isDesktop),
          validator: (value) =>
              value!.isEmpty ? 'Please enter your email' : null,
        ),
        const SizedBox(height: 20),

        // Role Label
        const Text(
          "I want to be a...",
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54),
        ),
        const SizedBox(height: 10),

        // Role Grid
        Row(
          children: [
            Expanded(
                child: _buildRoleCard(
                    title: 'Customer',
                    icon: Icons.shopping_bag_outlined,
                    value: 'user')),
            const SizedBox(width: 8),
            Expanded(
                child: _buildRoleCard(
                    title: 'Seller',
                    icon: Icons.storefront_outlined,
                    value: 'seller')),
            const SizedBox(width: 8),
            Expanded(
                child: _buildRoleCard(
                    title: 'Rider',
                    icon: Icons.motorcycle_outlined,
                    value: 'rider')),
          ],
        ),
        const SizedBox(height: 20),

        // Password
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
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
          validator: (value) => value!.length < 6 ? 'Password too short' : null,
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
    );
  }

  Widget _buildRoleCard(
      {required String title, required IconData icon, required String value}) {
    bool isSelected = _selectedRole == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey[400],
                size: 28),
            const SizedBox(height: 8),
            Text(title,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? const Color(0xFF1E3A8A)
                        : Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: const Color(0xFF1E3A8A).withValues(alpha: 0.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Create Account',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1)),
      ),
    );
  }

  Widget _buildLoginLink({required Color color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account?"),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Login",
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
