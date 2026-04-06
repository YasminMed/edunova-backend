import 'package:flutter/material.dart';
import 'dart:ui';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../widgets/animated_background.dart';
import '../widgets/custom_button.dart';
import 'login_lecturer.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';

class SignupLecturerPage extends StatefulWidget {
  final String departments;
  final String stages;

  const SignupLecturerPage({
    super.key,
    required this.departments,
    required this.stages,
  });

  @override
  State<SignupLecturerPage> createState() => _SignupLecturerPageState();
}

class _SignupLecturerPageState extends State<SignupLecturerPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String _selectedGender = 'Male';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    debugPrint("Sign up button pressed");
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _authService.signup(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          gender: _selectedGender,
          role: 'lecturer',
          department: widget.departments,
          stage: widget.stages,
        );

        if (!mounted) return;
        debugPrint("Form valid, showing dialog");
        // Simulate successful signup
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(
                          context,
                        )?.translate('account_created') ??
                        "Account Created!",
                    style: TextDesign.h2.copyWith(color: AppColors.primaryText),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(
                          context,
                        )?.translate('lecturer_account_created_subtitle') ??
                        "Your lecturer account has been created successfully.",
                    textAlign: TextAlign.center,
                    style: TextDesign.body,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text:
                        AppLocalizations.of(
                          context,
                        )?.translate('go_to_login') ??
                        "Go to Login",
                    onTap: () {
                      debugPrint("Navigating to login");
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginLecturerPage(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        final errorMsg = e.toString().toLowerCase();

        setState(() {
          if (errorMsg.contains("email") ||
              errorMsg.contains("already exists")) {
            _emailError = e.toString();
          } else if (errorMsg.contains("password")) {
            _passwordError = e.toString();
          } else if (errorMsg.contains("name")) {
            _nameError = e.toString();
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
    } else {
      debugPrint("Form invalid");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.translate('please_fill_all') ??
                "Please fill all fields correctly",
            style: TextDesign.body.copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
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
    String? Function(String?)? validator,
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
            validator:
                validator ??
                (value) {
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
      body: Stack(
        children: [
          const AnimatedBackground(),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back Button (Inline)
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: AppColors.primaryText,
                      ),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      alignment: AlignmentDirectional.centerStart,
                    ),

                    const SizedBox(height: 10),
                    // Title
                    Center(
                      child: Text(
                        AppLocalizations.of(
                              context,
                            )?.translate('lecturer_signup_title') ??
                            "Lecturer Signup",
                        style: TextDesign.h1.copyWith(fontSize: 32),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 30),

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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                            label:
                                AppLocalizations.of(
                                  context,
                                )?.translate('full_name') ??
                                "Full Name",
                            controller: _nameController,
                            icon: Icons.person_outline_rounded,
                            errorText: _nameError,
                            onChanged: (_) {
                              if (_nameError != null)
                                setState(() => _nameError = null);
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label:
                                AppLocalizations.of(
                                  context,
                                )?.translate('email') ??
                                "Email",
                            controller: _emailController,
                            icon: Icons.email_outlined,
                            errorText: _emailError,
                            onChanged: (_) {
                              if (_emailError != null)
                                setState(() => _emailError = null);
                            },
                          ),
                          const SizedBox(height: 16),
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
                            onChanged: (_) {
                              if (_passwordError != null)
                                setState(() => _passwordError = null);
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label:
                                AppLocalizations.of(
                                  context,
                                )?.translate('confirm_password') ??
                                "Confirm Password",
                            controller: _confirmPasswordController,
                            isPassword: true,
                            obscureText: _obscureConfirmPassword,
                            icon: Icons.lock_outline_rounded,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                            errorText: _confirmPasswordError,
                            onChanged: (_) {
                              if (_confirmPasswordError != null)
                                setState(() => _confirmPasswordError = null);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Gender Selection
                          Text(
                            AppLocalizations.of(context)?.translate('gender') ??
                                "Gender",
                            style: TextDesign.body.copyWith(
                              fontWeight: FontWeight.w500,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile<String>(
                                  title: Text(
                                    AppLocalizations.of(
                                          context,
                                        )?.translate('male') ??
                                        'Male',
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  value: 'Male',
                                  groupValue: _selectedGender,
                                  activeColor: AppColors.primary,
                                  onChanged: (val) =>
                                      setState(() => _selectedGender = val!),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<String>(
                                  title: Text(
                                    AppLocalizations.of(
                                          context,
                                        )?.translate('female') ??
                                        'Female',
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  value: 'Female',
                                  groupValue: _selectedGender,
                                  activeColor: AppColors.primary,
                                  onChanged: (val) =>
                                      setState(() => _selectedGender = val!),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),
                          CustomButton(
                            text:
                                AppLocalizations.of(
                                  context,
                                )?.translate('signup') ??
                                "Sign Up",
                            isLoading: _isLoading,
                            onTap: () {
                              _handleSignup();
                            },
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginLecturerPage(),
                                  ),
                                );
                              },
                              child: RichText(
                                text: TextSpan(
                                  text:
                                      AppLocalizations.of(
                                        context,
                                      )?.translate('already_have_account') ??
                                      "Already have an account? ",
                                  style: TextDesign.body.copyWith(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white70
                                        : AppColors.mutedText,
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          AppLocalizations.of(
                                            context,
                                          )?.translate('login') ??
                                          "Login",
                                      style: TextStyle(
                                        color: AppColors.secondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
