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
    final color = lecture['color'] as Color;
    final double progress = lecture['progress'] as double;

    return Hero(
      tag: 'lecture_card_${lecture['id']}',
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(isDark ? 0.12 : 0.08),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(32),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LectureDetailPage(lecture: lecture),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium Visual Header
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.9),
                        color.withOpacity(0.5),
                        color.withOpacity(0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Decorative Icon
                      Positioned(
                        right: -20,
                        top: -10,
                        child: Icon(
                          _getIconForCourse(lecture['subject']),
                          size: 160,
                          color: Colors.white.withOpacity(0.12),
                        ),
                      ),
                      // Floating Badge
                      Positioned(
                        top: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Text(
                            lecture['code'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                               padding: const EdgeInsets.all(12),
                               decoration: BoxDecoration(
                                 color: Colors.white.withOpacity(0.25),
                                 shape: BoxShape.circle,
                               ),
                               child: Icon(
                                 _getIconForCourse(lecture['subject']),
                                 color: Colors.white,
                                 size: 28,
                               ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lecture['subject'],
                        style: TextDesign.h2.copyWith(
                          color: isDark ? Colors.white : AppColors.primaryText,
                          fontSize: 24,
                          letterSpacing: -0.8,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        lecture['description'],
                        style: TextDesign.body.copyWith(
                          color: isDark ? Colors.white54 : Colors.grey[600],
                          fontSize: 14,
                          height: 1.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Icon(Icons.person_pin_rounded, size: 18, color: color.withOpacity(0.7)),
                          const SizedBox(width: 8),
                          Text(
                            lecture['professor'],
                            style: TextStyle(
                              color: isDark ? Colors.white70 : AppColors.primaryText,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "${(progress * 100).toInt()}%",
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Modern Progress Bar
                      Container(
                        height: 8,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress.clamp(0.01, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [color, color.withOpacity(0.7)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForCourse(String name) {
    name = name.toLowerCase();
    if (name.contains('math') || name.contains('calc')) return Icons.functions_rounded;
    if (name.contains('coding') || name.contains('program') || name.contains('se')) return Icons.code_rounded;
    if (name.contains('design') || name.contains('art')) return Icons.palette_rounded;
    if (name.contains('phys')) return Icons.science_rounded;
    if (name.contains('it') || name.contains('soft')) return Icons.computer_rounded;
    return Icons.menu_book_rounded;
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
