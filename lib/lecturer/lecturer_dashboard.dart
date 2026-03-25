import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../widgets/animated_background.dart';
import '../l10n/app_localizations.dart';
import '../student/music_page.dart';
import '../student/timetable_page.dart';
import '../providers/user_provider.dart';
import '../services/material_service.dart';
import 'student_analysis_page.dart';
import 'post_creation_page.dart';
import 'lecturer_materials_page.dart';
import 'lecturer_reports_page.dart';

class LecturerDashboard extends StatefulWidget {
  const LecturerDashboard({super.key});

  @override
  State<LecturerDashboard> createState() => _LecturerDashboardState();
}

class _LecturerDashboardState extends State<LecturerDashboard> {
  final ScrollController _scrollController = ScrollController();
  final MaterialService _materialService = MaterialService();
  
  int _materialsCount = 0;
  int _yearsExp = 0;
  bool _isLoading = true;

  final List<Map<String, String>> _activities = [
    {
      'title': 'Ali Hassan',
      'desc': 'Submitted Mathematics Assignment',
      'time': '10m ago',
    },
    {
      'title': 'Sarah Ahmed',
      'desc': 'Commented on your post',
      'time': '30m ago',
    },
    {
      'title': 'Exam System',
      'desc': 'Quzz 1 results generated',
      'time': '1h ago',
    },
    {
      'title': 'Yousif Mohammed',
      'desc': 'Asked a question in Chat',
      'time': '2h ago',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.email == null) return;
    
    try {
      final stats = await _materialService.fetchLecturerDashboardStats(userProvider.email!);
      if (mounted) {
        setState(() {
          _materialsCount = stats['materials'] ?? 0;
          _yearsExp = stats['years_exp'] ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _editYearsExp() async {
    final controller = TextEditingController(text: _yearsExp.toString());
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Experience"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Years of Experience",
            hintText: "Enter number of years",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null) {
                Navigator.pop(context, val);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (result != null && result != _yearsExp) {
      try {
        await _materialService.updateLecturerExperience(userProvider.email!, result);
        setState(() => _yearsExp = result);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update experience")),
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : AppColors.primaryText;
    final userProvider = Provider.of<UserProvider>(context);
    final lecturerName = userProvider.fullName ?? 'James';

    return Stack(
      children: [
        AnimatedBackground(scrollController: _scrollController),
        RefreshIndicator(
          onRefresh: _fetchStats,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${l10n?.translate('lecturer_welcome_back') ?? 'Welcome back'}, dr. $lecturerName!",
                  style: TextDesign.h1.copyWith(color: titleColor),
                ),
                const SizedBox(height: 24),

                // Stats Banner
                _buildStatsBanner(isDark),
                const SizedBox(height: 32),

                Text(
                  l10n?.translate('management_insights') ??
                      "Management & Insights",
                  style: TextDesign.h2.copyWith(color: titleColor),
                ),
                const SizedBox(height: 16),

                // Compact Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3, // Smaller cards
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.9,
                  children: [
                    _buildDashboardCard(
                      title: l10n?.translate('analysis') ?? "Analysis",
                      icon: Icons.analytics_rounded,
                      color: Colors.blueAccent,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StudentAnalysisPage(),
                        ),
                      ).then((_) => _fetchStats()),
                    ),
                    _buildDashboardCard(
                      title: l10n?.translate('post') ?? "Post",
                      icon: Icons.add_comment_rounded,
                      color: Colors.orange,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PostCreationPage(),
                        ),
                      ),
                    ),
                    _buildDashboardCard(
                      title: l10n?.translate('materials') ?? "Materials",
                      icon: Icons.library_add_rounded,
                      color: Colors.teal,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LecturerMaterialsPage(),
                        ),
                      ).then((_) => _fetchStats()),
                    ),
                    _buildDashboardCard(
                      title: l10n?.translate('timetable') ?? "Timetable",
                      icon: Icons.calendar_month_rounded,
                      color: Colors.purple,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TimetablePage()),
                      ),
                    ),
                    _buildDashboardCard(
                      title: l10n?.translate('music') ?? "Music",
                      icon: Icons.music_note_rounded,
                      color: Colors.pinkAccent,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MusicPage()),
                      ),
                    ),
                    _buildDashboardCard(
                      title: l10n?.translate('reports') ?? "Reports",
                      icon: Icons.description_rounded,
                      color: Colors.indigo,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LecturerReportsPage(),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
                Text(
                  l10n?.translate('latest_student_activities') ??
                      "Latest Student Activities",
                  style: TextDesign.h2.copyWith(color: titleColor),
                ),
                const SizedBox(height: 16),
                _buildActivityList(isDark),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsBanner(bool isDark) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.secondary.withOpacity(0.8), AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            _isLoading ? "..." : _materialsCount.toString(),
            l10n?.translate('materials') ?? "Materials",
          ),
          _buildStatSeparator(),
          GestureDetector(
            onTap: _editYearsExp,
            child: _buildStatItem(
              _isLoading ? "..." : _yearsExp.toString(),
              l10n?.translate('years_exp_short') ?? "Years Exp",
              isEditable: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, {bool isEditable = false}) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isEditable)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.edit, color: Colors.white70, size: 14),
              ),
          ],
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildStatSeparator() {
    return Container(height: 30, width: 1, color: Colors.white24);
  }

  Widget _buildDashboardCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextDesign.body.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.primaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityList(bool isDark) {
    return Column(
      children: _activities.map((activity) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.secondary.withOpacity(0.1),
                child: const Icon(
                  Icons.person,
                  color: AppColors.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity['title']!,
                      style: TextDesign.h3.copyWith(
                        fontSize: 14,
                        color: isDark ? Colors.white : AppColors.primaryText,
                      ),
                    ),
                    Text(
                      activity['desc']!,
                      style: TextDesign.small.copyWith(
                        color: isDark ? Colors.white70 : AppColors.bodyText,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                activity['time']!,
                style: TextDesign.small.copyWith(color: AppColors.mutedText),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
