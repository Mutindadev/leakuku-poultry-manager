import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leakuku/core/di.dart';
import 'package:leakuku/core/theme/app_colors.dart';
import 'package:leakuku/features/flock/presentation/providers/flock_provider.dart';
import 'package:leakuku/features/user/presentation/provider/user_provider.dart';

class LoginRegisterPage extends ConsumerStatefulWidget {
  const LoginRegisterPage({super.key});

  @override
  ConsumerState<LoginRegisterPage> createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends ConsumerState<LoginRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isLogin = true;
  String _role = 'Farmer';
  bool _obscurePassword = true;
  bool _redirected = false;
  bool _preparingDashboard = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final auth = ref.read(userProvider);
      if (auth.userModel != null && !auth.isLoading) {
        _prepareDashboard();
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _clearFields() {
    _emailController.clear();
    _passwordController.clear();
    _nameController.clear();
  }

  Future<void> _prepareDashboard() async {
    if (_redirected || _preparingDashboard) return;
    final userId = ref.read(userProvider).userModel?.uid;
    if (userId == null || userId.isEmpty) return;

    setState(() => _preparingDashboard = true);
    final flocks = ref.read(flockProvider.notifier);
    await flocks.loadFlocks();
    if (!mounted) return;

    try {
      await ref.read(firestoreSyncCoordinatorProvider).syncNow(userId);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not sync farm data. Check your connection.'),
          backgroundColor: Colors.red,
        ),
      );
      if (ref.read(flockProvider).flocks.isEmpty && _isLogin) {
        setState(() => _preparingDashboard = false);
        return;
      }
    }

    await flocks.loadFlocks();
    if (!mounted) return;

    _redirected = true;
    Navigator.of(context).pushReplacementNamed('/dashboard');
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.trim().length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<UserState>(userProvider, (previous, next) {
      if ((next.errorMessage ?? '').isNotEmpty) {
        // final isRegister = next.lastWasRegister == true;
        // final isInput = next.errorIsInput;
        // final bg = isInput
        //     ? Colors.amber.shade800
        //     : (isRegister ? Colors.orange.shade700 : Colors.red.shade700);
        // final prefix =
        //     isInput ? 'Input' : (isRegister ? 'Registration' : 'Login');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // content: Text('$prefix error: ${next.errorMessage}'),
            content: Text('Error: ${next.errorMessage}'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
      if (next.userModel != null && !next.isLoading) {
        _prepareDashboard();
      }
    });

    final auth = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: AppColors.farmCream,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.drumstickBite,
                      size: 60,
                      color: AppColors.leakukuGreen,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isLogin ? 'Welcome Back!' : 'Join LeaKuku',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF212121),
                              ),
                    ),
                    const SizedBox(height: 24),
                    if (!_isLogin) ...[
                      TextFormField(
                        controller: _nameController,
                        decoration:
                            _inputDecoration('Name', FontAwesomeIcons.user),
                        validator: _validateName,
                      ),
                      const SizedBox(height: 14),
                    ],
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration:
                          _inputDecoration('Email', FontAwesomeIcons.envelope),
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration:
                          _inputDecoration('Password', FontAwesomeIcons.lock)
                              .copyWith(
                        suffixIcon: IconButton(
                          icon: FaIcon(
                            _obscurePassword
                                ? FontAwesomeIcons.eyeSlash
                                : FontAwesomeIcons.eye,
                            size: 20,
                            color: AppColors.leakukuGreen,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: _validatePassword,
                    ),
                    if (!_isLogin) ...[
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: _role, // Changed from value
                        decoration:
                            _inputDecoration('Role', FontAwesomeIcons.userTag),
                        items: const ['Farmer', 'Admin']
                            .map((value) => DropdownMenuItem(
                                value: value, child: Text(value)))
                            .toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setState(() => _role = newValue);
                          }
                        },
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: auth.isLoading || _preparingDashboard
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  if (_isLogin) {
                                    await ref
                                        .read(userProvider.notifier)
                                        .handleSignIn(
                                          _emailController.text.trim(),
                                          _passwordController.text.trim(),
                                        );
                                  } else {
                                    await ref
                                        .read(userProvider.notifier)
                                        .handleRegister(
                                          _emailController.text.trim(),
                                          _passwordController.text.trim(),
                                          _nameController.text.trim(),
                                        );
                                  }
                                  if (mounted) await _prepareDashboard();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.leakukuGreen,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: auth.isLoading || _preparingDashboard
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : Text(
                                _isLogin ? 'LOGIN' : 'REGISTER',
                                style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                          _clearFields();
                        });
                      },
                      child: Text(
                        _isLogin
                            ? 'Don\'t have an account? Register'
                            : 'Already have an account? Login',
                        style: const TextStyle(color: Color(0xFFFF9800)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, FaIconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: FaIcon(icon, color: AppColors.leakukuGreen),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
