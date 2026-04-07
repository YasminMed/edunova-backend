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
            'description':
                c['description'] ??
                (AppLocalizations.of(context)?.translate('no_description') ??
                    'No description available.'),
            'professor':
                c['lecturer_name'] ??
                (AppLocalizations.of(context)?.translate('lecturer') ??
                    'Lecturer'),
            'progress': 0.0,
            'gradient': _getGradientColors(c['id']),
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
          ? Center(
              child: Text(
                l10n?.translate('no_courses_yet') ??
                    "No courses available yet.",
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.05, // More compact height
              ),
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
    final gradient = lecture['gradient'] as List<Color>;
    final mainColor = gradient[1];

    return Hero(
      tag: 'lecture_card_${lecture['id']}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LectureDetailPage(lecture: lecture),
              ),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  mainColor.withValues(alpha: isDark ? 0.3 : 0.6),
                  mainColor.withValues(alpha: isDark ? 0.1 : 0.25),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: mainColor.withValues(alpha: isDark ? 0.4 : 0.6),
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: mainColor.withValues(alpha: isDark ? 0.05 : 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // Abstract background icon circle similar to lecturer style
                  Positioned(
                    top: -25,
                    right: -25,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: mainColor.withValues(alpha: isDark ? 0.15 : 0.2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: mainColor.withValues(alpha: isDark ? 0.2 : 0.3),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: mainColor.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            _getIconForCourse(lecture['subject']),
                            color: isDark ? Colors.white : mainColor.withValues(alpha: 0.9),
                            size: 26,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          lecture['subject'],
                          style: TextDesign.h3.copyWith(
                            color: isDark ? Colors.white : AppColors.primaryText,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lecture['code'],
                          style: TextStyle(
                            color: isDark ? mainColor : mainColor.withValues(alpha: 0.8),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.person_rounded,
                              size: 14,
                              color: isDark ? mainColor : mainColor.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                lecture['professor'],
                                style: TextStyle(
                                  color: isDark ? Colors.white70 : AppColors.primaryText.withOpacity(0.7),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForCourse(String name) {
    name = name.toLowerCase();
    if (name.contains('math') || name.contains('calc'))
      return Icons.functions_rounded;
    if (name.contains('coding') ||
        name.contains('program') ||
        name.contains('se'))
      return Icons.code_rounded;
    if (name.contains('design') || name.contains('art'))
      return Icons.palette_rounded;
    if (name.contains('phys')) return Icons.science_rounded;
    if (name.contains('it') || name.contains('soft'))
      return Icons.computer_rounded;
    return Icons.menu_book_rounded;
  }

  List<Color> _getGradientColors(int seed) {
    final List<List<Color>> gradients = [
      [const Color(0xFFE3F2FD), const Color(0xFF64B5F6)], // Blue
      [const Color(0xFFF1F8E9), const Color(0xFF81C784)], // Green
      [const Color(0xFFFFF3E0), const Color(0xFFFFB74D)], // Orange
      [const Color(0xFFF3E5F5), const Color(0xFFBA68C8)], // Purple
      [const Color(0xFFE0F2F1), const Color(0xFF4DB6AC)], // Teal
      [const Color(0xFFFFFDE7), const Color(0xFFD4E157)], // Lime
    ];
    return gradients[seed % gradients.length];
  }
}
