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
            'professor': c['lecturer_name'] ?? 'Lecturer',
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
          : GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
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
    final color = lecture['color'] as Color;

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
              color: color.withOpacity(isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(isDark ? 0.1 : 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIconForCourse(lecture['subject']),
                      color: isDark ? color : color.withOpacity(0.8),
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    lecture['subject'],
                    style: TextDesign.h3.copyWith(
                      color: isDark ? Colors.white : AppColors.primaryText,
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
                      color: isDark ? Colors.white54 : Colors.grey[600],
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          lecture['professor'],
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.grey[700],
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
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
