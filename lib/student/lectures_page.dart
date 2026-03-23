import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../l10n/app_localizations.dart';
import '../services/material_service.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'lecture_detail_page.dart';

class LecturesPage extends StatefulWidget {
  const LecturesPage({super.key});

  @override
  State<LecturesPage> createState() => _LecturesPageState();
}

class _LecturesPageState extends State<LecturesPage> {
  final MaterialService _materialService = MaterialService();
  List<Map<String, dynamic>> _lectures = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLectures();
  }

  Future<void> _loadLectures() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final courses = await _materialService.getCourses(
        email: userProvider.email,
        role: userProvider.role,
      );
      setState(() {
        _lectures = courses.map((c) {
          return {
            'id': c['id'],
            'subject': c['name'],
            'code': c['code'] ?? 'CODE123',
            'description': c['description'] ?? 'No description available.',
            'professor': 'Lecturer', // Mock for now
            'progress': 0.0,
            'color': _getPastelColor(c['id']),
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n?.translate('lectures') ?? 'Lectures',
          style: TextDesign.h2.copyWith(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _lectures.isEmpty
          ? const Center(child: Text("No courses available yet."))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _lectures.length,
              itemBuilder: (context, index) {
                final lecture = _lectures[index];
                return _buildLectureCard(context, lecture);
              },
            ),
    );
  }

  Widget _buildLectureCard(BuildContext context, Map<String, dynamic> lecture) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = lecture['progress'] as double;
    final color = lecture['color'] as Color;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LectureDetailPage(lecture: lecture),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            // Course Header with colorful background
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      lecture['code'],
                      style: TextStyle(
                        color: color.withOpacity(0.8),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    lecture['subject'],
                    style: TextDesign.h2.copyWith(
                      color: isDark ? Colors.white : AppColors.primaryText,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    lecture['description'],
                    style: TextDesign.body.copyWith(
                      color: isDark ? Colors.white70 : Colors.grey[600],
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 16,
                        color: AppColors.mutedText,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        lecture['professor'],
                        style: TextDesign.body.copyWith(
                          color: AppColors.mutedText,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "${(progress * 100).toInt()}% Complete",
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: color.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Color _getPastelColor(int seed) {
    final List<Color> colors = [
      const Color(0xFFE3F2FD), // Light Blue
      const Color(0xFFF1F8E9), // Light Green
      const Color(0xFFFFF3E0), // Light Orange
      const Color(0xFFF3E5F5), // Light Purple
      const Color(0xFFE0F2F1), // Light Teal
      const Color(0xFFFFFDE7), // Light Yellow
    ];
    return colors[seed % colors.length];
  }
}
