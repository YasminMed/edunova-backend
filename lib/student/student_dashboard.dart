import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/material_service.dart';
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

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 2; // Default to Dashboard
  final ScrollController _scrollController = ScrollController();
  final MaterialService _materialService = MaterialService();

  double _progressValue = 0.0;
  String _rankText = "";
  int _totalMarks = 0;

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.email == null) return;

    try {
      final data = await _materialService.getStudentProgress(
        userProvider.email!,
      );
      if (mounted) {
        setState(() {
          _progressValue = (data['progress'] as num).toDouble() / 100.0;
          _rankText =
              data['rank_text'] ??
              (AppLocalizations.of(context)?.translate('rank_pending') ??
                  "Rank Pending");
          _totalMarks = data['total_academic_marks'] ?? 0;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _rankText =
              AppLocalizations.of(context)?.translate('score_pending') ??
              "Score Pending";
        });
      }
    }
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
    return IndexedStack(
      index: _selectedIndex,
      children: [
        const StudentProfilePage(),
        const ChatPage(),
        _buildDashboardContent(),
        const StudentChatbotPage(),
        const SettingsPage(),
      ],
    );
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
                Theme.of(
                  context,
                ).scaffoldBackgroundColor.withValues(alpha: 0.3),
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
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : const Color(0xFFFBFDFF),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.03),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextDesign.h3.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextDesign.body.copyWith(
                      color: isDark ? Colors.white60 : AppColors.mutedText,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.mutedText.withOpacity(0.3),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : const Color(0xFFFBFDFF),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.02),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 25,
            offset: const Offset(0, 12),
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
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)?.translate('keep_going') ??
                      "Perfect, keep going!",
                  style: TextDesign.body.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
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
                        _rankText,
                        style: TextDesign.body.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.stars_rounded,
                            color: Colors.amber,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "$_totalMarks",
                            style: TextDesign.body.copyWith(
                              color: Colors.amber[800],
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 85,
                height: 85,
                child: CircularProgressIndicator(
                  value: _progressValue,
                  backgroundColor: AppColors.primary.withOpacity(0.08),
                  color: AppColors.primary,
                  strokeWidth: 9,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text(
                "${(_progressValue * 100).toInt()}%",
                style: TextDesign.h3.copyWith(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.primaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
                    : AppColors.primary.withOpacity(0.12))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? (isDark ? Colors.white : AppColors.primary)
                  : (isDark ? Colors.white38 : AppColors.mutedText),
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white : AppColors.primary,
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
                ? Colors.white.withOpacity(0.05)
                : const Color(0xFFFBFDFF).withOpacity(0.95),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.white.withOpacity(0.4),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black26
                    : Colors.blueGrey.withOpacity(0.06),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(widget.icon, color: widget.color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                widget.title,
                style: TextDesign.body.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 0.1,
                  color: isDark
                      ? Colors.white.withOpacity(0.9)
                      : AppColors.primaryText,
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
