import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../l10n/app_localizations.dart';

class RanksPage extends StatefulWidget {
  const RanksPage({super.key});

  @override
  State<RanksPage> createState() => _RanksPageState();
}

class _RanksPageState extends State<RanksPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _slideAnimation;

  final List<Map<String, dynamic>> _students = [
    {
      'name': 'Ahmed Ali',
      'score': 98.5,
      'rank': 1,
      'color': const Color(0xFFFFD700),
      'gradient': [const Color(0xFFFFE000), const Color(0xFFFFB000)],
    }, // Vibrant Yellow/Gold
    {
      'name': 'Sara Hassan',
      'score': 96.2,
      'rank': 2,
      'color': const Color(0xFFFF8C00),
      'gradient': [const Color(0xFFFFAB40), const Color(0xFFFF6D00)],
    }, // Vibrant Orange
    {
      'name': 'Yousif Mohammed',
      'score': 94.8,
      'rank': 3,
      'color': const Color(0xFF4CAF50),
      'gradient': [const Color(0xFF81C784), const Color(0xFF2E7D32)],
    }, // Vibrant Green
    {
      'name': 'Noora Omar',
      'score': 92.5,
      'rank': 4,
      'color': Colors.blue,
      'gradient': [Colors.blue, Colors.blueAccent],
    },
    {
      'name': 'Zaid Khalid',
      'score': 91.0,
      'rank': 5,
      'color': Colors.purple,
      'gradient': [Colors.purple, Colors.purpleAccent],
    },
    {
      'name': 'Lana Bakir',
      'score': 89.4,
      'rank': 6,
      'color': Colors.teal,
      'gradient': [Colors.teal, Colors.tealAccent],
    },
    {
      'name': 'Karwan Aziz',
      'score': 88.0,
      'rank': 7,
      'color': Colors.cyan,
      'gradient': [Colors.cyan, Colors.cyanAccent],
    },
    {
      'name': 'Darya Hawre',
      'score': 87.5,
      'rank': 8,
      'color': Colors.pinkAccent,
      'gradient': [Colors.pinkAccent, Colors.pink],
    },
  ];

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
    _animController.forward();
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
      body: Column(
        children: [
          // Podium Section
          _buildPodium(context),

          const SizedBox(height: 24),

          // Leaderboard List
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
                  itemCount: _students.length - 3,
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
              const Text(
                "pts",
                style: TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRankingTile(BuildContext context, Map<String, dynamic> student) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          const Text(
            "pts",
            style: TextStyle(color: AppColors.mutedText, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
