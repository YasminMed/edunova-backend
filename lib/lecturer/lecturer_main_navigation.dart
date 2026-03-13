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
            bottom: 24,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(30),
                    border: Theme.of(context).brightness == Brightness.dark
                        ? null
                        : Border.all(
                            color: Theme.of(
                              context,
                            ).dividerColor.withOpacity(0.6),
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withOpacity(0.2),
                        blurRadius: 25,
                        spreadRadius: -5,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(Icons.person_outline_rounded, 0),
                      _buildNavItem(Icons.chat_bubble_outline_rounded, 1),
                      _buildNavItem(Icons.dashboard_rounded, 2),
                      _buildNavItem(Icons.smart_toy_outlined, 3),
                      _buildNavItem(Icons.settings_outlined, 4),
                    ],
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
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondary.withOpacity(0.1)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? AppColors.secondary : AppColors.mutedText,
          size: 26,
        ),
      ),
    );
  }
}
