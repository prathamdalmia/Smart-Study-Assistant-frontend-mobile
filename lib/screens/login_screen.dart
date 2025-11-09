import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';
import '../widgets/background_design.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late AnimationController _animController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final ok = await auth.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (ok && mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: BackgroundDesign(
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      Hero(
                        tag: 'app-logo',
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(35),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.4),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                                spreadRadius: -5,
                              ),
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Image(
                              image: AssetImage('assets/logo.png'),
                              width: 180,
                              height: 180,
                            ),
                          ),
                        ),
                      )
                          .animate()
                          .scale(
                            delay: 200.ms,
                            duration: 600.ms,
                            curve: Curves.elasticOut,
                          )
                          .fadeIn(delay: 200.ms),
                      const SizedBox(height: 40),
                      // Title
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 400.ms)
                          .slideY(begin: 0.2, end: 0, delay: 400.ms),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to continue your learning journey',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 500.ms)
                          .slideY(begin: 0.2, end: 0, delay: 500.ms),
                      const SizedBox(height: 40),
                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'Email or Username',
                          labelStyle: TextStyle(color: Colors.grey.shade600),
                          prefixIcon: Icon(Icons.person_outline,
                              color: AppTheme.primaryColor),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email or username';
                          }
                          return null;
                        },
                      )
                          .animate()
                          .fadeIn(delay: 600.ms)
                          .slideX(begin: -0.2, end: 0, delay: 600.ms),
                      const SizedBox(height: 20),
                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.grey.shade600),
                          prefixIcon: Icon(Icons.lock_outline,
                              color: AppTheme.primaryColor),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.grey.shade600,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      )
                          .animate()
                          .fadeIn(delay: 700.ms)
                          .slideX(begin: -0.2, end: 0, delay: 700.ms),
                      const SizedBox(height: 32),
                      // Login Button
                      GradientButton(
                        text: 'Sign In',
                        onPressed: auth.loading ? null : _submit,
                        isLoading: auth.loading,
                        icon: Icons.arrow_forward_rounded,
                      )
                          .animate()
                          .fadeIn(delay: 800.ms)
                          .scale(delay: 800.ms, duration: 400.ms),
                      const SizedBox(height: 24),
                      // Sign Up Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context)
                                .pushReplacementNamed('/signup'),
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 900.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
