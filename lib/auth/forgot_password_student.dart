import 'package:flutter/material.dart';
import 'dart:ui';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../widgets/animated_background.dart';
import '../widgets/custom_button.dart';
import 'verification_code_student.dart';
import '../l10n/app_localizations.dart';

class ForgotPasswordStudentPage extends StatefulWidget {
  const ForgotPasswordStudentPage({super.key});

  @override
  State<ForgotPasswordStudentPage> createState() =>
      _ForgotPasswordStudentPageState();
}

class _ForgotPasswordStudentPageState extends State<ForgotPasswordStudentPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
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
                          )?.translate('forgot_password') ??
                          "Forgot Password",
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
                          )?.translate('enter_email_subtitle') ??
                          "Enter your email to receive a verification code",
                      style: TextDesign.body.copyWith(
                        color: isDark
                            ? Colors.white70
                            : AppColors.primaryText.withOpacity(0.7),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)?.translate('email') ??
                                "Email Address",
                            style: TextDesign.body.copyWith(
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Theme.of(context).cardColor
                                  : Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white24
                                    : AppColors.primary.withOpacity(0.2),
                              ),
                            ),
                            child: TextFormField(
                              controller: _emailController,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color,
                              ),
                              decoration: const InputDecoration(
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: AppColors.primary,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(16),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(value)) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 32),
                          CustomButton(
                            text:
                                AppLocalizations.of(
                                  context,
                                )?.translate('send_code') ??
                                "Send Code",
                            onTap: () {
                              if (_formKey.currentState!.validate()) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const VerificationCodeStudentPage(),
                                  ),
                                );
                              }
                            },
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
