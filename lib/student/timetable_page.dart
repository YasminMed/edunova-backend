import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../l10n/app_localizations.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  String _selectedDay = 'sun';

  final Map<String, List<Map<String, dynamic>>> _schedule = {
    'sun': [
      {
        'material': 'Mathematics',
        'lecturer': 'Dr. Ahmed',
        'hall': '101',
        'start': '08:30',
        'end': '10:00',
        'color': Colors.blue,
      },
      {
        'material': 'Physics',
        'lecturer': 'Dr. Sara',
        'hall': '204',
        'start': '10:30',
        'end': '12:00',
        'color': Colors.orange,
      },
      {
        'material': 'Programming',
        'lecturer': 'Prof. Zaid',
        'hall': 'Lab 1',
        'start': '01:00',
        'end': '03:00',
        'color': Colors.purple,
      },
    ],
    'mon': [
      {
        'material': 'English',
        'lecturer': 'Ms. Noor',
        'hall': '305',
        'start': '09:00',
        'end': '10:30',
        'color': Colors.green,
      },
      {
        'material': 'Mathematics',
        'lecturer': 'Dr. Ahmed',
        'hall': '101',
        'start': '11:00',
        'end': '12:30',
        'color': Colors.blue,
      },
    ],
    'tue': [
      {
        'material': 'Science',
        'lecturer': 'Dr. Lena',
        'hall': 'Lab 3',
        'start': '08:30',
        'end': '11:00',
        'color': Colors.teal,
      },
      {
        'material': 'Database',
        'lecturer': 'Prof. Karwan',
        'hall': 'Lab 2',
        'start': '12:00',
        'end': '02:00',
        'color': Colors.indigo,
      },
    ],
    'wed': [
      {
        'material': 'Programming',
        'lecturer': 'Prof. Zaid',
        'hall': 'Lab 1',
        'start': '09:00',
        'end': '11:30',
        'color': Colors.purple,
      },
      {
        'material': 'Networking',
        'lecturer': 'Dr. Aziz',
        'hall': '402',
        'start': '12:00',
        'end': '01:30',
        'color': Colors.deepOrange,
      },
    ],
    'thu': [
      {
        'material': 'Soft Skills',
        'lecturer': 'Ms. Lana',
        'hall': 'Seminar Hall',
        'start': '10:00',
        'end': '12:00',
        'color': Colors.pink,
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final days = ['sun', 'mon', 'tue', 'wed', 'thu'];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n?.translate('timetable_page') ?? 'Class Timetable',
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
          // Day Filter
          Container(
            height: 60,
            margin: const EdgeInsets.symmetric(vertical: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: days.length,
              itemBuilder: (context, index) {
                final day = days[index];
                final isSelected = _selectedDay == day;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDay = day),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? Colors.white : AppColors.primary)
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Text(
                      l10n?.translate(day) ?? day.toUpperCase(),
                      style: TextDesign.body.copyWith(
                        color: isSelected
                            ? (isDark ? Colors.black87 : Colors.white)
                            : isDark
                            ? Colors.white70
                            : AppColors.mutedText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Schedule List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              itemCount: _schedule[_selectedDay]?.length ?? 0,
              itemBuilder: (context, index) {
                final lecture = _schedule[_selectedDay]![index];
                return _buildLectureCard(context, lecture);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLectureCard(BuildContext context, Map<String, dynamic> lecture) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Colored Side Strip
            Container(
              width: 8,
              decoration: BoxDecoration(
                color: lecture['color'],
                borderRadius: const BorderRadiusDirectional.horizontal(
                  start: Radius.circular(20),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Time Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    lecture['start'],
                    style: TextDesign.h3.copyWith(
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.mutedText,
                    size: 16,
                  ),
                  Text(
                    lecture['end'],
                    style: TextDesign.body.copyWith(
                      color: AppColors.mutedText,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Vertical Divider
            VerticalDivider(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
              thickness: 1,
              indent: 20,
              endIndent: 20,
            ),
            const SizedBox(width: 16),
            // Lecture Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lecture['material'],
                      style: TextDesign.h3.copyWith(
                        fontSize: 18,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline_rounded,
                          size: 14,
                          color: AppColors.mutedText,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          lecture['lecturer'],
                          style: TextDesign.body.copyWith(
                            color: AppColors.mutedText,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: lecture['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${l10n?.translate('hall') ?? 'Hall'} ${lecture['hall']}",
                        style: TextStyle(
                          color: lecture['color'],
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
