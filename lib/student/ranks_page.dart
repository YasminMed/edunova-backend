import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/auth_service.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class RanksPage extends StatefulWidget {
  const RanksPage({super.key});

  @override
  State<RanksPage> createState() => _RanksPageState();
}

class _RanksPageState extends State<RanksPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _slideAnimation;
  final Dio _dio = Dio();

  List<Map<String, dynamic>> _students = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _slideAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = context.read<UserProvider>();
      final response = await _dio.get(
        "${AuthService.baseUrl}/student/leaderboard",
        queryParameters: {
          if (user.department != null) "department": user.department,
          if (user.stage != null) "stage": user.stage,
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        if (!mounted) return;
        setState(() {
          _students = data.map((item) {
            int rank = item['rank'];
            Color baseColor = Colors.blue;
            List<Color> gradient = [Colors.blue, Colors.blueAccent];

            if (rank == 1) {
              baseColor = const Color(0xFFFFD700);
              gradient = [const Color(0xFFFFE000), const Color(0xFFFFB000)];
            } else if (rank == 2) {
              baseColor = const Color(0xFFFF8C00);
              gradient = [const Color(0xFFFFAB40), const Color(0xFFFF6D00)];
            } else if (rank == 3) {
              baseColor = const Color(0xFF4CAF50);
              gradient = [const Color(0xFF81C784), const Color(0xFF2E7D32)];
            } else {
              // Cycle through some colors for others
              final colors = [
                Colors.blue,
                Colors.purple,
                Colors.teal,
                Colors.cyan,
                Colors.pinkAccent,
              ];
              baseColor = colors[(rank - 4) % colors.length];
              gradient = [baseColor, baseColor.withOpacity(0.7)];
            }

            return {
              'name': item['name'],
              'score': item['score'],
              'rank': rank,
              'color': baseColor,
              'gradient': gradient,
            };
          }).toList();
          _isLoading = false;
        });
        _animController.forward(from: 0);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            AppLocalizations.of(context)?.translate('retry') ??
            "Connection error. Please try again later.";
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n?.translate('ranks_page') ?? 'Student Ranks',
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
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_errorMessage!, style: TextDesign.body),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchLeaderboard,
                    child: Text(l10n?.translate('retry') ?? "Retry"),
                  ),
                ],
              ),
            )
          : _students.isEmpty
          ? Center(
              child: Text(
                l10n?.translate('no_ranking_data') ?? "No ranking data yet",
              ),
            )
          : Column(
              children: [
                if (_students.length >= 3) _buildPodium(context),
                const SizedBox(height: 24),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(40),
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 24,
                        ),
                        itemCount: _students.length <= 3
                            ? 0
                            : _students.length - 3,
                        itemBuilder: (context, index) {
                          final student = _students[index + 3];
                          return _buildRankingTile(context, student);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPodium(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ScaleTransition(
        scale: _slideAnimation,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 3rd Place (Left)
            _buildPodiumItem(context, _students[2], 100, 0.7),
            // 1st Place (Middle)
            _buildPodiumItem(context, _students[0], 140, 1.0, isFirst: true),
            // 2nd Place (Right)
            _buildPodiumItem(context, _students[1], 120, 0.85),
          ],
        ),
      ),
    );
  }

  Widget _buildPodiumItem(
    BuildContext context,
    Map<String, dynamic> student,
    double height,
    double scale, {
    bool isFirst = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isFirst)
          const Icon(
            Icons.workspace_premium_rounded,
            color: Color(0xFFFFD700),
            size: 30,
          ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (student['gradient'] as List<Color>)[0].withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 35 * scale,
                backgroundColor: (student['gradient'] as List<Color>)[1]
                    .withOpacity(0.2),
                child: Icon(
                  Icons.person_rounded,
                  color: (student['gradient'] as List<Color>)[0],
                  size: 35 * scale,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: student['gradient'] as List<Color>,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    "${student['rank']}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          student['name'].split(' ')[0],
          style: TextDesign.h3.copyWith(
            fontSize: 14 * scale,
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: isFirst ? FontWeight.bold : FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: student['gradient'] as List<Color>,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${student['score']}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                l10n?.translate('pts') ?? "pts",
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRankingTile(BuildContext context, Map<String, dynamic> student) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            alignment: Alignment.center,
            child: Text(
              "#${student['rank']}",
              style: TextDesign.h3.copyWith(
                color: AppColors.mutedText,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 20,
            backgroundColor: student['color'].withOpacity(0.1),
            child: Icon(
              Icons.person_rounded,
              color: student['color'],
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              student['name'],
              style: TextDesign.body.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Text(
            "${student['score']}",
            style: TextDesign.h3.copyWith(
              color: isDark ? Colors.white : AppColors.primary,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            l10n?.translate('pts') ?? "pts",
            style: const TextStyle(color: AppColors.mutedText, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
