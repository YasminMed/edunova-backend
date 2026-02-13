import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../l10n/app_localizations.dart';

class StudentSocialFeedPage extends StatelessWidget {
  const StudentSocialFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Latest Posts",
          style: TextDesign.h2.copyWith(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildPostCard(
            context,
            userName: "Dean Wilson",
            time: "2h ago",
            title:
                AppLocalizations.of(context)?.translate('post_sports_title') ??
                "Annual Sports Meet 2024",
            description:
                AppLocalizations.of(context)?.translate('post_sports_desc') ??
                "Join us this Friday for the biggest sports event of the semester! Registration is open now at the faculty office.",
            image:
                "https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=800&auto=format&fit=crop&q=60",
            likes: 124,
            comments: 18,
          ),
          const SizedBox(height: 20),
          _buildPostCard(
            context,
            userName: "Academic Office",
            time: "5h ago",
            title:
                AppLocalizations.of(
                  context,
                )?.translate('post_achievement_title') ??
                "New Achievement Unlocked!",
            description:
                AppLocalizations.of(
                  context,
                )?.translate('post_achievement_desc') ??
                "Congratulations to our Computer Science department for winning the regional Innovation Challenge. Proud of our team!",
            image:
                "https://images.unsplash.com/photo-1531403009284-440f080d1e12?w=800&auto=format&fit=crop&q=60",
            likes: 342,
            comments: 45,
          ),
          const SizedBox(height: 20),
          _buildPostCard(
            context,
            userName: "Student Council",
            time: "1d ago",
            title:
                AppLocalizations.of(context)?.translate('post_ball_title') ??
                "Winter Ball Tickets",
            description:
                AppLocalizations.of(context)?.translate('post_ball_desc') ??
                "Early bird tickets for the Winter Ball are now available. Get yours before they run out!",
            likes: 89,
            comments: 12,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPostCard(
    BuildContext context, {
    required String userName,
    required String time,
    required String title,
    required String description,
    String? image,
    required int likes,
    required int comments,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).cardColor : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        userName[0],
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          time,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.more_horiz_rounded,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.grey[600],
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          if (image != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  image,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _buildInteractionBtn(
                  Icons.favorite_outline_rounded,
                  likes.toString(),
                  Colors.redAccent,
                ),
                const SizedBox(width: 24),
                _buildInteractionBtn(
                  Icons.chat_bubble_outline_rounded,
                  comments.toString(),
                  AppColors.primary,
                ),
                const SizedBox(width: 24),
                _buildInteractionBtn(
                  Icons.share_outlined,
                  AppLocalizations.of(context)?.translate('share') ?? "Share",
                  Colors.blueAccent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionBtn(IconData icon, String label, Color color) {
    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
