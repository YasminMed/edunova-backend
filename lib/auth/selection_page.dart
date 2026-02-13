import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../widgets/animated_background.dart';
import '../widgets/custom_button.dart';
import 'login_student.dart';
import 'login_lecturer.dart';
import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';

// Selection Logic Provider (unchanged logic)
class SelectionProvider extends ChangeNotifier {
  void selectRole(String role) {
    print("Selected Role: $role");
  }
}

class SelectionPage extends StatelessWidget {
  const SelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SelectionProvider(),
      child: const _SelectionPageView(),
    );
  }
}

class _SelectionPageView extends StatelessWidget {
  const _SelectionPageView();

  void _showStudentIdDialog(BuildContext context) {
    final TextEditingController idController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)?.translate('student_verification') ??
                  "Student Verification",
              style: TextDesign.h2.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)?.translate('enter_university_id') ??
                  "Enter your University ID to continue",
              style: TextDesign.body.copyWith(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: idController,
              decoration: InputDecoration(
                labelText:
                    AppLocalizations.of(context)?.translate('university_id') ??
                    "University ID",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text:
                  AppLocalizations.of(context)?.translate('submit') ?? "Submit",
              onTap: () {
                if (idController.text.isNotEmpty) {
                  Navigator.pop(context); // Close dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginStudentPage()),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLecturerIdDialog(BuildContext context) {
    final TextEditingController idController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(
                    context,
                  )?.translate('lecturer_verification') ??
                  "Lecturer Verification",
              style: TextDesign.h2.copyWith(color: AppColors.secondary),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)?.translate('enter_lecturer_id') ??
                  "Enter your Lecturer ID to continue",
              style: TextDesign.body.copyWith(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: idController,
              decoration: InputDecoration(
                labelText:
                    AppLocalizations.of(context)?.translate('lecturer_id') ??
                    "Lecturer ID",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.secondary,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text:
                  AppLocalizations.of(context)?.translate('submit') ?? "Submit",
              onTap: () {
                if (idController.text.isNotEmpty) {
                  Navigator.pop(context); // Close dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginLecturerPage(),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Reusable Animated Background
          const AnimatedBackground(),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Language Switcher
                  Align(
                    alignment: Alignment.centerRight,
                    child: PopupMenuButton<Locale>(
                      icon: const Icon(
                        Icons.language,
                        color: AppColors.primaryText,
                      ),
                      onSelected: (Locale locale) {
                        context.read<LocaleProvider>().setLocale(locale);
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<Locale>>[
                            const PopupMenuItem<Locale>(
                              value: Locale('en'),
                              child: Text('English'),
                            ),
                            const PopupMenuItem<Locale>(
                              value: Locale('ar'),
                              child: Text('العربية'),
                            ),
                            const PopupMenuItem<Locale>(
                              value: Locale('ckb'),
                              child: Text('کوردی'),
                            ),
                          ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Brand Identity
                  Center(
                    child: Image.asset(
                      "assets/edunova_logo.png",
                      width: 120,
                      height: 120,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.auto_awesome_rounded,
                        size: 60,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    AppLocalizations.of(context)?.translate('choose_role') ??
                        "Choose your role",
                    style: TextDesign.h1.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(
                          context,
                        )?.translate('welcome_subtitle') ??
                        "Start your journey with EduNova",
                    style: TextDesign.body,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Cards
                  _RoleCard(
                    title:
                        AppLocalizations.of(context)?.translate('student') ??
                        "Student",
                    icon: Icons.school_rounded,
                    color: AppColors.primary,
                    onTap: () {
                      context.read<SelectionProvider>().selectRole('student');
                      _showStudentIdDialog(context);
                    },
                  ),
                  const SizedBox(height: 24),
                  _RoleCard(
                    title:
                        AppLocalizations.of(context)?.translate('lecturer') ??
                        "Lecturer",
                    icon: Icons.person_outline_rounded,
                    color: AppColors.secondary,
                    onTap: () {
                      context.read<SelectionProvider>().selectRole('lecturer');
                      _showLecturerIdDialog(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8), // Glass effect
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadiusDirectional.horizontal(
                  start: Radius.circular(16),
                ),
              ),
            ),
            const SizedBox(width: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(width: 24),
            Expanded(child: Text(title, style: TextDesign.h2)),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.mutedText,
              size: 20,
            ),
            const SizedBox(width: 24),
          ],
        ),
      ),
    );
  }
}
