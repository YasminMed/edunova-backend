import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../widgets/animated_background.dart';
import '../widgets/custom_button.dart';
import 'forgot_password_lecturer.dart';
import '../lecturer/lecturer_main_navigation.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import 'department_stage_selection.dart';
import '../providers/user_provider.dart';

class LoginLecturerPage extends StatefulWidget {
  const LoginLecturerPage({super.key});

  @override
  State<LoginLecturerPage> createState() => _LoginLecturerPageState();
}

class _LoginLecturerPageState extends State<LoginLecturerPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;
  bool _obscurePassword = true;

  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final userData = await _authService.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          'lecturer',
        );
        if (!mounted) return;

        final userProvider = context.read<UserProvider>();
        await userProvider.setUser(
          userData['fullName'] ?? 'Lecturer',
          _emailController.text.trim(),
          'lecturer',
          department: userData['department'],
          stage: userData['stage'],
          photoUrl: userData['image_url'],
        );

        if (!userProvider.isProfileComplete) {
          // Redirect to complete profile
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const DepartmentStageSelectionPage(
                role: 'lecturer',
                isLogin: true,
                isUpdateProfile: true,
              ),
            ),
            (route) => false,
          );
        } else {
          // Navigate to Lecturer Dashboard
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LecturerMainNavigation()),
            (route) => false,
          );
        }
      } catch (e) {
        if (!mounted) return;
        final errorMsg = e.toString().toLowerCase();

        setState(() {
          if (errorMsg.contains("email") ||
              errorMsg.contains("not registered")) {
            _emailError = e.toString();
          } else if (errorMsg.contains("password") ||
              errorMsg.contains("incorrect")) {
            _passwordError = e.toString();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString()),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        });
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool isPassword = false,
    bool obscureText = false,
    IconData? icon,
    Widget? suffixIcon,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextDesign.body.copyWith(
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white24
                  : AppColors.primary.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.primaryText,
            ),
            decoration: InputDecoration(
              prefixIcon: icon != null
                  ? Icon(icon, color: AppColors.primary)
                  : null,
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              hintText: label,
              hintStyle: TextStyle(
                color: isDark ? Colors.white54 : Colors.grey,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            onChanged: onChanged,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter $label';
              }
              if (!isPassword &&
                  label.toLowerCase().contains('email') &&
                  !RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                return 'Please enter a valid email (e.g. user@example.com)';
              }
              if (isPassword && value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              return null;
            },
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              errorText,
              style: TextDesign.caption.copyWith(
                color: Colors.redAccent,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.primaryText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          const AnimatedBackground(),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    // Title
                    Text(
                      AppLocalizations.of(
                            context,
                          )?.translate('lecturer_login_title') ??
                          "Lecturer Login",
                      style: TextDesign.h1.copyWith(fontSize: 32),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(
                            context,
                          )?.translate('lecturer_welcome_back') ??
                          "Welcome back, Professor!",
                      style: TextDesign.body,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Neon Container
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).dividerColor.withOpacity(0.8),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.15),
                            blurRadius: 30,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildTextField(
                            label:
                                AppLocalizations.of(
                                  context,
                                )?.translate('email') ??
                                "Email",
                            controller: _emailController,
                            icon: Icons.email_outlined,
                            errorText: _emailError,
                            onChanged: (val) {
                              if (_emailError != null) {
                                setState(() => _emailError = null);
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            label:
                                AppLocalizations.of(
                                  context,
                                )?.translate('password') ??
                                "Password",
                            controller: _passwordController,
                            isPassword: true,
                            obscureText: _obscurePassword,
                            icon: Icons.lock_outline_rounded,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            errorText: _passwordError,
                            onChanged: (val) {
                              if (_passwordError != null) {
                                setState(() => _passwordError = null);
                              }
                            },
                          ),

                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const ForgotPasswordLecturerPage(),
                                  ),
                                );
                              },
                              child: Text(
                                AppLocalizations.of(
                                      context,
                                    )?.translate('forgot_password') ??
                                    "Forgot Password?",
                                style: TextDesign.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),
                          CustomButton(
                            text:
                                AppLocalizations.of(
                                  context,
                                )?.translate('login') ??
                                "Login",
                            isLoading: _isLoading,
                            onTap: () {
                              _handleLogin();
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(
                                context,
                              )?.translate('dont_have_account') ??
                              "Don't have an account?",
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const DepartmentStageSelectionPage(
                                      role: 'lecturer',
                                      isLogin: false,
                                    ),
                              ),
                            );
                          },
                          child: Text(
                            AppLocalizations.of(context)?.translate('signup') ??
                                "Sign Up",
                            style: TextDesign.body.copyWith(
                              color: AppColors.primary,
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
          ),
        ],
      ),
    );
  }
}
