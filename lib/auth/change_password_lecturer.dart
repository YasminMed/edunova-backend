import 'package:flutter/material.dart';
import 'dart:ui';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../widgets/animated_background.dart';
import '../widgets/custom_button.dart';
import 'login_lecturer.dart';
import '../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';

class ChangePasswordLecturerPage extends StatefulWidget {
  const ChangePasswordLecturerPage({super.key});

  @override
  State<ChangePasswordLecturerPage> createState() =>
      _ChangePasswordLecturerPageState();
}

class _ChangePasswordLecturerPageState
    extends State<ChangePasswordLecturerPage> {
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _oldPassError;

  @override
  void dispose() {
    _oldPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _oldPassError = null;
    });

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final userProvider = context.read<UserProvider>();
      try {
        await _authService.changePassword(
          email: userProvider.email!,
          oldPassword: _oldPassController.text,
          newPassword: _newPassController.text,
          role: 'lecturer',
        );

        if (!mounted) return;
        setState(() => _isLoading = false);

        showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
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
                    AppLocalizations.of(context)?.translate('success') ??
                        "Success!",
                    style: TextDesign.h2,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(
                          context,
                        )?.translate('password_changed') ??
                        "Your password has been changed.",
                    textAlign: TextAlign.center,
                    style: TextDesign.body,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text:
                        AppLocalizations.of(
                          context,
                        )?.translate('back_to_login') ??
                        "Back to Login",
                    onTap: () {
                      // Navigate back to Login and remove all previous routes
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
        setState(() {
          _isLoading = false;
          if (e.toString().contains("Incorrect previous password")) {
            _oldPassError = "Incorrect previous password";
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString()),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextDesign.body.copyWith(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: true,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            decoration: const InputDecoration(
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                color: AppColors.primary,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(
                            context,
                          )?.translate('reset_password') ??
                          "Reset Password",
                      style: TextDesign.h1.copyWith(
                        fontSize: 28,
                        color: isDark ? Colors.white : null,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(
                            context,
                          )?.translate('reset_password_subtitle') ??
                          "Create a new password for your account",
                      style: TextDesign.body.copyWith(
                        color: isDark ? Colors.white70 : null,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Theme.of(context).cardColor
                            : Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.8),
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
                            label: "Previous Password",
                            controller: _oldPassController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              return _oldPassError;
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            label:
                                AppLocalizations.of(
                                  context,
                                )?.translate('new_password') ??
                                "New Password",
                            controller: _newPassController,
                            validator: (value) {
                              if (value == null || value.length < 8) {
                                return 'Must be at least 8 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            label:
                                AppLocalizations.of(
                                  context,
                                )?.translate('confirm_password') ??
                                "Confirm Password",
                            controller: _confirmPassController,
                            validator: (value) {
                              if (value != _newPassController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                          _isLoading
                              ? const CircularProgressIndicator()
                              : CustomButton(
                                  text:
                                      AppLocalizations.of(
                                        context,
                                      )?.translate('change_password') ??
                                      "Change Password",
                                  onTap: _handleSubmit,
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
