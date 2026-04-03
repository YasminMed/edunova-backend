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
  List<dynamic> _activities = [];

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
          _activities = stats['activities'] ?? [];
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
    final l10n = AppLocalizations.of(context);

    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.translate('edit_experience') ?? "Edit Experience"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: l10n?.translate('years_exp_label') ?? "Years of Experience",
            hintText: () {
              final field = l10n?.translate('enter_field');
              final label = l10n?.translate('years_exp_label') ?? 'years';
              return field != null ? field.replaceFirst('{field}', label) : "Enter number of years";
            }(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n?.translate('cancel') ?? "Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null) {
                Navigator.pop(ctx, val);
              }
            },
            child: Text(l10n?.translate('save') ?? "Save"),
          ),
        ],
      ),
    );

    if (result != null && result != _yearsExp) {
      try {
        await _materialService.updateLecturerExperience(userProvider.email!, result);
        if (mounted) setState(() => _yearsExp = result);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n?.translate('failed_to_update_experience') ?? "Failed to update experience")),
          );
        }
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
                  crossAxisCount: 3, 
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.05, // More compact
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
                _isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : _activities.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: [
                              Icon(Icons.history_rounded, size: 48, color: titleColor.withOpacity(0.2)),
                              const SizedBox(height: 12),
                              Text(
                                l10n?.translate('no_recent_activity') ?? "No recent activities found",
                                style: TextStyle(color: titleColor.withOpacity(0.5)),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _buildActivityList(isDark),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E3A8A).withOpacity(0.95), // Deep Professional Indigo
            const Color(0xFF1E40AF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E40AF).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
      borderRadius: BorderRadius.circular(28),
      child: Container(
        decoration: BoxDecoration(
          color: isDark 
              ? Colors.white.withOpacity(0.05) 
              : const Color(0xFFFBFDFF).withOpacity(0.95), // Premium off-white
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark 
                ? Colors.white.withOpacity(0.08) 
                : Colors.white.withOpacity(0.4),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.blueGrey.withOpacity(0.06),
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
              padding: const EdgeInsets.all(10), // Reduced from 14
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 24), // Reduced from 28
            ),
            const SizedBox(height: 8), // Reduced from 12
            Text(
              title,
              style: TextDesign.body.copyWith(
                fontSize: 11, // Reduced from 13
                fontWeight: FontWeight.w800,
                letterSpacing: 0.1,
                color: isDark ? Colors.white.withOpacity(0.9) : AppColors.primaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'quiz_submitted':
        return Icons.quiz_rounded;
      case 'assignment_submitted':
        return Icons.assignment_turned_in_rounded;
      case 'comment_added':
        return Icons.comment_rounded;
      case 'material_viewed':
        return Icons.visibility_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'quiz_submitted':
        return Colors.orange;
      case 'assignment_submitted':
        return Colors.blue;
      case 'comment_added':
        return Colors.teal;
      case 'material_viewed':
        return Colors.purple;
      default:
        return AppColors.primary;
    }
  }

  Widget _buildActivityList(bool isDark) {
    final l10n = AppLocalizations.of(context);
    if (_activities.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.history_rounded, size: 48, color: Colors.grey.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              l10n?.translate('no_recent_activity') ?? "No recent activity",
              style: TextStyle(
                color: Colors.grey.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _activities.map((activity) {
        final type = activity['type'] ?? 'default';
        final icon = _getActivityIcon(type);
        final color = _getActivityColor(type);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.03),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
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
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity['title'] ?? 'Notification',
                      style: TextDesign.body.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: isDark ? Colors.white : AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getLocalizedActivityDesc(context, activity),
                      style: TextDesign.body.copyWith(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                activity['time'] ?? '',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _getLocalizedActivityDesc(BuildContext context, Map<String, dynamic> activity) {
    final l10n = AppLocalizations.of(context);
    final type = activity['type'] ?? 'default';
    final desc = activity['desc'] ?? '';
    
    String actionKey = 'activity_unknown';
    String englishAction = '';
    
    switch (type) {
      case 'quiz_submitted':
        actionKey = 'activity_quiz_submitted';
        englishAction = 'Submitted quiz';
        break;
      case 'assignment_submitted':
        actionKey = 'activity_assignment_submitted';
        englishAction = 'Submitted assignment';
        break;
      case 'comment_added':
        actionKey = 'activity_comment_added';
        englishAction = 'Added a comment';
        break;
      case 'material_viewed':
        actionKey = 'activity_material_viewed';
        englishAction = 'Viewed material';
        break;
    }
    
    if (actionKey == 'activity_unknown') return desc;
    
    final localizedAction = l10n?.translate(actionKey) ?? englishAction;
    
    // Try to extract the name of the assignment/quiz/etc from the English desc
    // Format usually is "Action 'Name'" or "'Action 'Name'"
    String content = "";
    if (desc.contains("'")) {
      // Find where the English action ends or where the first quote of the name starts
      int nameStart = desc.toLowerCase().indexOf(englishAction.toLowerCase());
      if (nameStart != -1) {
        nameStart += englishAction.length;
        content = desc.substring(nameStart).trim();
      } else {
        // Fallback: find the first quote that isn't at the very start
        int firstQuote = desc.indexOf("'", desc.startsWith("'") ? 1 : 0);
        if (firstQuote != -1) {
          content = desc.substring(firstQuote).trim();
        }
      }
    } else if (desc.toLowerCase().startsWith(englishAction.toLowerCase())) {
      content = desc.substring(englishAction.length).trim();
    }
    
    return content.isEmpty ? localizedAction : "$localizedAction $content";
  }
}
