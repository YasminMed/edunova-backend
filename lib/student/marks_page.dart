import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'package:dio/dio.dart';
import '../services/auth_service.dart';

class MarksPage extends StatefulWidget {
  const MarksPage({super.key});

  @override
  State<MarksPage> createState() => _MarksPageState();
}

class _MarksPageState extends State<MarksPage> {
  final Dio _dio = Dio();
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _marksData;

  @override
  void initState() {
    super.initState();
    _fetchMarks();
  }

  Future<void> _fetchMarks() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final email = userProvider.email;

    if (email == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = "User email not found";
      });
      return;
    }

    try {
      final response = await _dio.get(
        "${AuthService.baseUrl}/student/academic-marks",
        queryParameters: {"student_email": email},
      );

      if (response.statusCode == 200) {
        setState(() {
          _marksData = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load marks: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error connecting to server";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n?.translate('marks_page') ?? 'Academic Marks',
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
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!, style: TextDesign.body),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _errorMessage = null;
                          });
                          _fetchMarks();
                        },
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    // Hero Section: Final Mark
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: _buildFinalMarkHero(context),
                      ),
                    ),

                    // Subjects List Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                        child: Text(
                          l10n?.translate('subjects') ?? 'Subjects',
                          style: TextDesign.h3.copyWith(
                            color: isDark ? Colors.white : AppColors.primary,
                          ),
                        ),
                      ),
                    ),

                    // Subjects List
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final subject = _marksData!['subjects'][index];
                          return _buildSubjectCard(context, subject);
                        }, childCount: _marksData!['subjects'].length),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  ],
                ),
    );
  }

  Widget _buildFinalMarkHero(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final finalMark = _marksData!['final_mark'];
    final feedback = _marksData!['feedback'];
    final rank = _marksData!['rank'];
    final totalStudents = _marksData!['total_students'];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1E26), const Color(0xFF2D2D3A)]
              : [const Color(0xFF2ECC71), const Color(0xFF27AE60)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2ECC71).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  value: finalMark / 100,
                  strokeWidth: 10,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              Text(
                "$finalMark%",
                style: TextDesign.h2.copyWith(
                  color: Colors.white,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.translate('final_mark') ?? 'Final Mark',
                  style: TextDesign.h3.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feedback,
                  style: TextDesign.body.copyWith(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Rank: $rank / $totalStudents",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(BuildContext context, Map<String, dynamic> subject) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final String iconType = subject['icon_type'] ?? 'math';
    final Color subjectColor = iconType == 'math' 
        ? Colors.blue 
        : iconType == 'science' 
            ? Colors.green 
            : Colors.purple;
    
    final IconData icon = iconType == 'math' 
        ? Icons.calculate_rounded 
        : iconType == 'science' 
            ? Icons.science_rounded 
            : Icons.code_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: subjectColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: subjectColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject['name'],
                      style: TextDesign.h3.copyWith(
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      "${l10n?.translate('grade') ?? 'Grade'}: ${subject['grade']}",
                      style: TextDesign.body.copyWith(
                        color: AppColors.mutedText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "${subject['mark']}%",
                style: TextDesign.h3.copyWith(color: subjectColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (subject['mark'] as num).toDouble() / 100,
              minHeight: 6,
              backgroundColor: subjectColor.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(subjectColor),
            ),
          ),
        ],
      ),
    );
  }
}
