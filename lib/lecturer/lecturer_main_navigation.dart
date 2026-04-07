import 'package:flutter/material.dart';
import 'dart:ui';
import '../constants/app_colors.dart';

import 'lecturer_dashboard.dart';
import 'lecturer_profile_page.dart';
import 'lecturer_chat_page.dart';
import 'lecturer_chatbot_page.dart';
import 'lecturer_settings_page.dart';

class LecturerMainNavigation extends StatefulWidget {
  const LecturerMainNavigation({super.key});

  @override
  State<LecturerMainNavigation> createState() => _LecturerMainNavigationState();
}

class _LecturerMainNavigationState extends State<LecturerMainNavigation> {
  int _selectedIndex = 2; // Default to Dashboard

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Body Content
          _buildBody(),

          // Bottom Navigation Bar
          Positioned(
            left: 20,
            right: 20,
            bottom: bottomPadding > 0 ? bottomPadding : 24,
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B).withOpacity(0.95) // Dark Slate
                    : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(36),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.03),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
                    blurRadius: 30,
                    spreadRadius: -2,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(36),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(Icons.person_rounded, 0),
                        _buildNavItem(Icons.chat_bubble_rounded, 1),
                        _buildNavItem(Icons.grid_view_rounded, 2),
                        _buildNavItem(Icons.smart_toy_rounded, 3),
                        _buildNavItem(Icons.settings_rounded, 4),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const LecturerProfilePage();
      case 1:
        return const LecturerChatPage();
      case 2:
        return const LecturerDashboard();
      case 3:
        return const LecturerChatbotPage();
      case 4:
        return const LecturerSettingsPage();
      default:
        return const LecturerDashboard();
    }
  }

  Widget _buildNavItem(IconData icon, int index) {
    final bool isSelected = _selectedIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                    ? Colors.white.withOpacity(0.08)
                    : AppColors.secondary.withOpacity(0.12))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? (isDark ? Colors.white : AppColors.secondary)
                  : (isDark ? Colors.white38 : AppColors.mutedText),
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white : AppColors.secondary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
