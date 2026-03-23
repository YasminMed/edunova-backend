import 'package:flutter/material.dart';
import 'dart:ui';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../widgets/animated_background.dart';
import '../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'chat_page.dart';
import 'student_profile_page.dart';
import 'student_chatbot_page.dart';
import 'settings_page.dart';
import 'marks_page.dart';
import 'ranks_page.dart';
import 'medals_page.dart';
import 'timetable_page.dart';
import 'fees_page.dart';
import 'music_page.dart';
import 'faculty_page.dart';
import 'lectures_page.dart';
import 'student_challenges_page.dart';
import 'student_social_feed_page.dart';
import 'student_social_feed_page.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 2; // Default to Dashboard
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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

          // Bottom Navigation Bar with Enhanced Shadow
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
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
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 25,
                            spreadRadius: -5,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildNavItem(Icons.person_outline_rounded, 0),
                          _buildNavItem(Icons.chat_bubble_outline_rounded, 1),
                          _buildNavItem(Icons.dashboard_rounded, 2),
                          _buildNavItem(
                            Icons.smart_toy_outlined,
                            3,
                          ), // AI Agent
                          _buildNavItem(Icons.settings_outlined, 4),
                        ],
                      ),
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
        return const StudentProfilePage();
      case 1:
        return const ChatPage();
      case 2:
        return _buildDashboardContent();
      case 3:
        return const StudentChatbotPage();
      case 4:
        return const SettingsPage();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    return Stack(
      children: [
        // Parallax Background
        AnimatedBackground(scrollController: _scrollController),

        // Foreground Content with Fade Effect at Bottom
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).scaffoldBackgroundColor,
                Theme.of(context).scaffoldBackgroundColor,
                Theme.of(context).scaffoldBackgroundColor.withOpacity(0.3),
              ],
              stops: const [0.0, 0.7, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(
              top: 60,
              bottom: 160, // Increased to avoid navbar overlap
              left: 20,
              right: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Greeting)
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    final name = userProvider.fullName ?? "Student";
                    return Text(
                      "${AppLocalizations.of(context)?.translate('hello') ?? 'Hello'}, $name!",
                      style: TextDesign.h1.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87,
                      ),
                    );
                  },
                ),
                Text(
                  AppLocalizations.of(context)?.translate('ready_to_learn') ??
                      "Ready to learn something new today?",
                  style: TextDesign.body.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : AppColors.mutedText,
                  ),
                ),
                const SizedBox(height: 24),

                // Progress Card
                _buildProgressCard(),
                const SizedBox(height: 24),

                // Horizontal Grid Menu (2 Rows)
                SizedBox(
                  height: 240,
                  child: GridView.count(
                    scrollDirection: Axis.horizontal,
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    padding: const EdgeInsets.only(right: 20),
                    children: [
                      _DashboardGridItem(
                        title:
                            AppLocalizations.of(context)?.translate('marks') ??
                            "Marks",
                        icon: Icons.grade_rounded,
                        color: Colors.amber,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MarksPage(),
                            ),
                          );
                        },
                      ),
                      _DashboardGridItem(
                        title:
                            AppLocalizations.of(context)?.translate('medals') ??
                            "Medals",
                        icon: Icons.emoji_events_rounded,
                        color: Colors.orange,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MedalsPage(),
                            ),
                          );
                        },
                      ),
                      _DashboardGridItem(
                        title:
                            AppLocalizations.of(context)?.translate('ranks') ??
                            "Ranks",
                        icon: Icons.leaderboard_rounded,
                        color: Colors.blueAccent,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RanksPage(),
                            ),
                          );
                        },
                      ),
                      _DashboardGridItem(
                        title:
                            AppLocalizations.of(context)?.translate('fees') ??
                            "Fees",
                        icon: Icons.payment_rounded,
                        color: Colors.green,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FeesPage(),
                            ),
                          );
                        },
                      ),
                      _DashboardGridItem(
                        title:
                            AppLocalizations.of(
                              context,
                            )?.translate('timetable') ??
                            "Timetable",
                        icon: Icons.calendar_today_rounded,
                        color: Colors.purple,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TimetablePage(),
                            ),
                          );
                        },
                      ),
                      _DashboardGridItem(
                        title:
                            AppLocalizations.of(
                              context,
                            )?.translate('lectures') ??
                            "Lectures",
                        icon: Icons.menu_book_rounded,
                        color: Colors.teal,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LecturesPage(),
                            ),
                          );
                        },
                      ),
                      _DashboardGridItem(
                        title:
                            AppLocalizations.of(context)?.translate('music') ??
                            "Music",
                        icon: Icons.music_note_rounded,
                        color: Colors.pinkAccent,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MusicPage(),
                            ),
                          );
                        },
                      ),
                      _DashboardGridItem(
                        title:
                            AppLocalizations.of(
                              context,
                            )?.translate('faculty') ??
                            "Faculty",
                        icon: Icons.people_alt_rounded,
                        color: Colors.cyan,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FacultyPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  AppLocalizations.of(context)?.translate('events') ??
                      "Events & Updates",
                  style: TextDesign.h2.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                // Events Section
                _buildEventCard(
                  title:
                      AppLocalizations.of(
                        context,
                      )?.translate('weekly_challenges') ??
                      "Weekly Challenges",
                  subtitle:
                      AppLocalizations.of(
                        context,
                      )?.translate('participate_badges') ??
                      "Participate and earn badges!",
                  icon: Icons.local_fire_department_rounded,
                  color: Colors.deepOrange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StudentChallengesPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildEventCard(
                  title:
                      AppLocalizations.of(context)?.translate('latest_posts') ??
                      "Latest Posts",
                  subtitle:
                      AppLocalizations.of(context)?.translate('check_campus') ??
                      "Check out what's new in campus",
                  icon: Icons.newspaper_rounded,
                  color: Colors.indigo,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StudentSocialFeedPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              isDark
                  ? Theme.of(context).cardColor
                  : Theme.of(context).cardColor.withOpacity(0.9),
              isDark
                  ? Theme.of(context).cardColor.withOpacity(0.7)
                  : Theme.of(context).cardColor.withOpacity(0.6),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: isDark
              ? Border.all(color: Colors.white.withOpacity(0.05))
              : null,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextDesign.h3.copyWith(
                      fontSize: 18,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextDesign.body.copyWith(
                      color: AppColors.mutedText,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.mutedText.withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).cardColor
                : Theme.of(context).cardColor.withOpacity(0.8),
            Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).cardColor.withOpacity(0.8)
                : Theme.of(context).cardColor.withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)?.translate('progress') ??
                      "Your Progress",
                  style: TextDesign.h2.copyWith(
                    fontSize: 22,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)?.translate('keep_going') ??
                      "Perfect, keep going!",
                  style: TextDesign.body.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    AppLocalizations.of(context)?.translate('top_class') ??
                        "Top 5% of Class",
                    style: TextDesign.body.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Circular Progress Only
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).cardColor.withOpacity(0.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: CircularProgressIndicator(
                  value: 0.78,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  color: AppColors.primary,
                  strokeWidth: 8,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "78%",
                    style: TextDesign.h3.copyWith(
                      fontSize: 20,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
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
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? AppColors.primary : AppColors.mutedText,
          size: 26,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  }
}

class _DashboardGridItem extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardGridItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_DashboardGridItem> createState() => _DashboardGridItemState();
}

class _DashboardGridItemState extends State<_DashboardGridItem>
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
      end: 0.95,
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
    widget.onTap();
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
          decoration: BoxDecoration(
            color: isDark
                ? Theme.of(context).cardColor
                : Theme.of(context).cardColor.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: isDark
                ? Border.all(color: Colors.white.withOpacity(0.05))
                : null,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, color: widget.color, size: 28),
              ),
              const SizedBox(height: 10),
              Text(
                widget.title,
                style: TextDesign.body.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
