import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../widgets/animated_background.dart';
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
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.0,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppColors.primaryText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(
                          context,
                        )?.translate('welcome_subtitle') ??
                        "Start your journey with EduNova",
                    style: TextDesign.body.copyWith(
                      fontSize: 16,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : AppColors.mutedText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 56),

                  // Cards
                  _RoleCard(
                    title:
                        AppLocalizations.of(context)?.translate('student') ??
                        "Student",
                    icon: Icons.school_rounded,
                    color: AppColors.primary,
                    onTap: () {
                      context.read<SelectionProvider>().selectRole('student');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginStudentPage(),
                        ),
                      );
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginLecturerPage(),
                        ),
                      );
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

class _RoleCard extends StatefulWidget {
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
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap(); // Execute tap action
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: 130, // Deeper card
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.4)
                    : widget.color.withOpacity(0.15),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.white.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.white.withOpacity(0.5),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      decoration: BoxDecoration(
                        color: widget.color,
                        borderRadius: const BorderRadiusDirectional.horizontal(
                          start: Radius.circular(24),
                        ),
                        boxShadow: isDark
                            ? [
                                BoxShadow(
                                  color: widget.color.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : [],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Container(
                      padding: const EdgeInsets.all(16), // Larger icon pad
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.color.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(widget.icon, size: 36, color: widget.color),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: TextDesign.h2.copyWith(
                          color: isDark ? Colors.white : AppColors.primaryText,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: isDark ? Colors.white38 : AppColors.mutedText,
                      size: 20,
                    ),
                    const SizedBox(width: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
