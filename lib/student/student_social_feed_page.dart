import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../l10n/app_localizations.dart';
import '../services/post_service.dart';
import '../services/auth_service.dart';

class StudentSocialFeedPage extends StatefulWidget {
  const StudentSocialFeedPage({super.key});

  @override
  State<StudentSocialFeedPage> createState() => _StudentSocialFeedPageState();
}

class _StudentSocialFeedPageState extends State<StudentSocialFeedPage> {
  final PostService _postService = PostService();
  List<dynamic> _posts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    try {
      final posts = await _postService.getPosts();
      setState(() {
        _posts = posts;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

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
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: isDark ? Colors.white : Colors.black87),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchPosts();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 60),
                      const SizedBox(height: 16),
                      Text("Failed to load posts", style: TextDesign.h3),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(_errorMessage!, textAlign: TextAlign.center, style: TextDesign.body),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          setState(() => _isLoading = true);
                          _fetchPosts();
                        },
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              : _posts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.post_add_rounded, color: Colors.grey[400], size: 80),
                          const SizedBox(height: 16),
                          Text("No posts yet", style: TextDesign.h3.copyWith(color: Colors.grey)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchPosts,
                      color: AppColors.primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        physics: const BouncingScrollPhysics(),
                        itemCount: _posts.length,
                        itemBuilder: (context, index) {
                          final post = _posts[index];
                          final String? imageUrl = post['image_url'];
                          final fullImageUrl = imageUrl != null ? "${AuthService.baseUrl}$imageUrl" : null;
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: _buildPostCard(
                              context,
                              userName: post['author_name'] ?? "Lecturer",
                              time: _formatTimestamp(post['created_at']),
                              title: post['title'] ?? "No Title",
                              description: post['description'] ?? "",
                              image: fullImageUrl,
                              likes: 0,
                              comments: 0,
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  String _formatTimestamp(String? isoDate) {
    if (isoDate == null) return "Just now";
    try {
      final date = DateTime.parse(isoDate);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
      if (diff.inHours < 24) return "${diff.inHours}h ago";
      return "${diff.inDays}d ago";
    } catch (_) {
      return "Recently";
    }
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
