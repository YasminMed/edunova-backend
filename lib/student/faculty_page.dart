import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../l10n/app_localizations.dart';
import '../services/material_service.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../providers/user_provider.dart';
import 'chat_detail_page.dart';

class FacultyPage extends StatefulWidget {
  const FacultyPage({super.key});

  @override
  State<FacultyPage> createState() => _FacultyPageState();
}

class _FacultyPageState extends State<FacultyPage> {
  final MaterialService _materialService = MaterialService();
  List<dynamic> _lecturers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLecturers();
  }

  Future<void> _loadLecturers() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final data = await _materialService.getTeachingStaff(
        department: userProvider.department,
        stage: userProvider.stage,
      );
      if (mounted) {
        setState(() {
          _lecturers = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
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
          l10n?.translate('faculty') ?? 'Teaching Staff',
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
          : _lecturers.isEmpty
              ? Center(
                  child: Text(
                    AppLocalizations.of(context)?.translate('no_lecturers_found') ?? "No lecturers found for your stage.",
                    style: TextDesign.body.copyWith(color: AppColors.mutedText),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _lecturers.length,
                  itemBuilder: (context, index) {
                    return _buildTeacherCard(context, _lecturers[index]);
                  },
                ),
    );
  }

  Widget _buildTeacherCard(BuildContext context, Map<String, dynamic> teacher) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = Colors.primaries[teacher['id'] % Colors.primaries.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
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
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      color,
                      color.withOpacity(0.3),
                    ],
                  ),
                ),
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: color.withOpacity(0.2),
                  backgroundImage: teacher['image_url'] != null
                      ? NetworkImage("${AuthService.baseUrl}${teacher['image_url']}")
                      : null,
                  child: teacher['image_url'] == null
                      ? Text(
                          teacher['fullName'][0].toUpperCase(),
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacher['fullName'],
                      style: TextDesign.h3.copyWith(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      teacher['department'] ?? "",
                      style: TextDesign.body.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${teacher['years_of_experience']} ${AppLocalizations.of(context)?.translate('years_exp_label') ?? 'Years Experience'}",
                      style: TextDesign.body.copyWith(
                        color: AppColors.mutedText,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _contactLecturer(teacher),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    AppLocalizations.of(context)?.translate('contact_button') ?? "Contact",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)?.translate('coming_soon') ?? 'Profile feature coming soon!')),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _contactLecturer(Map<String, dynamic> lecturer) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final chatService = ChatService();
    
    if (userProvider.email != null) {
      final session = await chatService.startChatSession(
        userProvider.email!,
        lecturer['id'],
      );
      
      if (session != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailPage(
              sessionId: session.sessionId,
              otherUserEmail: lecturer['email'],
              name: lecturer['fullName'],
              avatarColor: Colors.blueAccent,
              isGroup: false,
            ),
          ),
        );
      }
    }
  }
}
