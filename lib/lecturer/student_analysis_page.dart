import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';

class StudentAnalysisPage extends StatefulWidget {
  const StudentAnalysisPage({super.key});

  @override
  State<StudentAnalysisPage> createState() => _StudentAnalysisPageState();
}

class _StudentAnalysisPageState extends State<StudentAnalysisPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _chartData = [0.4, 0.7, 0.5, 0.9, 0.6, 0.8, 0.75];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.primaryText;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Student Analysis",
          style: TextDesign.h2.copyWith(color: textColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChartCard(isDark),
            const SizedBox(height: 24),
            Text(
              "Attendance Analytics",
              style: TextDesign.h2.copyWith(color: textColor),
            ),
            const SizedBox(height: 16),
            _buildAttendanceAnalytics(isDark),
            const SizedBox(height: 24),
            Text(
              "Detailed Statistics",
              style: TextDesign.h2.copyWith(color: textColor),
            ),
            const SizedBox(height: 16),
            _buildStatGrid(isDark),
            const SizedBox(height: 24),
            Text(
              "Top Performers",
              style: TextDesign.h2.copyWith(color: textColor),
            ),
            const SizedBox(height: 16),
            _buildTopPerformers(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceAnalytics(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAttendanceCircle("Attended", 0.85, Colors.green),
              _buildAttendanceCircle("Late", 0.10, Colors.orange),
              _buildAttendanceCircle("Absent", 0.05, Colors.red),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Average Attendance Rate: 92%",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCircle(String label, double percentage, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        SizedBox(
          height: 60,
          width: 60,
          child: CircularProgressIndicator(
            value: percentage,
            strokeWidth: 8,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white70 : Colors.grey[700],
          ),
        ),
        Text(
          "${(percentage * 100).toInt()}%",
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildChartCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Class Performance Trend",
            style: TextDesign.h3.copyWith(
              color: isDark ? Colors.white : AppColors.secondary,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: LineChartPainter(_chartData, _controller.value),
                  size: Size.infinite,
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Mon", style: TextStyle(fontSize: 10)),
              Text("Tue", style: TextStyle(fontSize: 10)),
              Text("Wed", style: TextStyle(fontSize: 10)),
              Text("Thu", style: TextStyle(fontSize: 10)),
              Text("Fri", style: TextStyle(fontSize: 10)),
              Text("Sat", style: TextStyle(fontSize: 10)),
              Text("Sun", style: TextStyle(fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatGrid(bool isDark) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildMiniStat("Average Mark", "84%", Icons.grade, Colors.green),
        _buildMiniStat("Engagement", "92%", Icons.bolt, Colors.orange),
        _buildMiniStat("Attendance", "95%", Icons.event_available, Colors.blue),
        _buildMiniStat("Materials Used", "120", Icons.book, Colors.purple),
      ],
    );
  }

  Widget _buildMiniStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : Colors.grey[600],
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPerformers(bool isDark) {
    final performers = [
      {'name': 'Ali Hassan', 'grade': 'A+', 'color': Colors.amber},
      {'name': 'Sarah Ahmed', 'grade': 'A', 'color': Colors.grey[400]},
      {'name': 'Yousif Mohammed', 'grade': 'A-', 'color': Colors.brown[300]},
    ];

    return Column(
      children: performers.map((p) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: (p['color'] as Color).withOpacity(0.2),
                child: Text(
                  (p['grade'] as String)[0],
                  style: TextStyle(color: p['color'] as Color),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                p['name'] as String,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.primaryText,
                ),
              ),
              const Spacer(),
              Text(
                p['grade'] as String,
                style: TextStyle(
                  color: p['color'] as Color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<double> data;
  final double progress;

  LineChartPainter(this.data, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final dx = size.width / (data.length - 1);

    for (var i = 0; i < data.length; i++) {
      final x = i * dx;
      final y = size.height - (data[i] * size.height * progress);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw dots
    final dotPaint = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.fill;
    for (var i = 0; i < data.length; i++) {
      final x = i * dx;
      final y = size.height - (data[i] * size.height * progress);
      canvas.drawCircle(Offset(x, y), 5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant LineChartPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
