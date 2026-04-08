import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../services/post_service.dart';
import '../services/auth_service.dart';
import '../providers/user_provider.dart';
import '../widgets/share_post_bottom_sheet.dart';
import '../l10n/app_localizations.dart';

class PostCreationPage extends StatefulWidget {
  const PostCreationPage({super.key});

  @override
  State<PostCreationPage> createState() => _PostCreationPageState();
}

class _PostCreationPageState extends State<PostCreationPage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final PostService _postService = PostService();

  String _activeTab = "New"; // "New" or "Posted"
  File? _selectedImage;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _isUploading = false;

  List<dynamic> _myPosts = [];
  bool _isLoadingHistory = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _fetchMyPosts() async {
    setState(() => _isLoadingHistory = true);
    try {
      final posts = await _postService.getPosts();
      // In a real app we'd filter by lecturer ID, but here we show all for simplicity
      setState(() {
        _myPosts = posts;
        _isLoadingHistory = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingHistory = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error loading posts: $e")));
      }
    }
  }

  Future<void> _deletePost(int id) async {
    try {
      await _postService.deletePost(id);
      _fetchMyPosts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Post deleted successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Delete failed: $e")));
      }
    }
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    bool hasFile =
        result != null &&
        (kIsWeb
            ? result.files.single.bytes != null
            : result.files.single.path != null);

    if (hasFile) {
      setState(() {
        if (kIsWeb) {
          _selectedImageBytes = result.files.single.bytes;
          _selectedImageName = result.files.single.name;
          _selectedImage = null;
        } else {
          _selectedImage = File(result.files.single.path!);
          _selectedImageBytes = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.primaryText;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.translate('create_post_title') ??
              "Create Post",
          style: TextDesign.h2.copyWith(color: textColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Column(
        children: [
          _buildTabFilter(isDark),
          Expanded(
            child: _activeTab == "New"
                ? _buildNewPostSection(isDark)
                : _buildPostedHistorySection(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildTabFilter(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          _buildTabItem("New", isDark),
          _buildTabItem("Posted", isDark),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, bool isDark) {
    final isSelected = _activeTab == title;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => _activeTab = title);
          if (title == "Posted") _fetchMyPosts();
        },
        borderRadius: BorderRadius.circular(15),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.secondary : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white70 : Colors.black54),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNewPostSection(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildInputCard(isDark),
          const SizedBox(height: 24),
          if (_selectedImage != null || _selectedImageBytes != null)
            _buildImagePreview(),
          const SizedBox(height: 24),
          _buildMediaSection(isDark),
          const SizedBox(height: 30),
          _buildPostButton(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: kIsWeb
              ? Image.memory(
                  _selectedImageBytes!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                )
              : Image.file(
                  _selectedImage!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: GestureDetector(
            onTap: () => setState(() {
              _selectedImage = null;
              _selectedImageBytes = null;
              _selectedImageName = null;
            }),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPostedHistorySection(bool isDark) {
    if (_isLoadingHistory) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (_myPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "No posts yet",
              style: TextDesign.h3.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchMyPosts,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _myPosts.length,
        itemBuilder: (context, index) {
          final post = _myPosts[index];
          final String? imageUrl = post['image_url'];
          final fullImageUrl = AuthService.resolveUrl(imageUrl);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.secondary.withValues(
                        alpha: 0.1,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post['author_email'] ==
                                    Provider.of<UserProvider>(
                                      context,
                                      listen: false,
                                    ).email
                                ? "You"
                                : (post['author_name'] ?? "Lecturer"),
                            style: TextDesign.body.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _formatTimestamp(post['created_at']),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (post['author_email'] ==
                        Provider.of<UserProvider>(context, listen: false).email)
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.redAccent,
                        ),
                        onPressed: () => _showDeleteDialog(post['id']),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(post['title'] ?? "", style: TextDesign.h3),
                const SizedBox(height: 8),
                Text(post['description'] ?? "", style: TextDesign.body),
                if (fullImageUrl.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      fullImageUrl,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      post['has_liked'] == true
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      "${post['likes_count'] ?? 0} Likes",
                      color: post['has_liked'] == true
                          ? Colors.redAccent
                          : Colors.grey,
                      onTap: () async {
                        final userProvider = Provider.of<UserProvider>(
                          context,
                          listen: false,
                        );
                        if (userProvider.email != null) {
                          bool hasLiked = post['has_liked'] == true;
                          setState(() {
                            post['has_liked'] = !hasLiked;
                            post['likes_count'] = (post['likes_count'] ?? 0) + (hasLiked ? -1 : 1);
                          });
                          try {
                            final result = await _postService.likePost(
                              post['id'],
                              userProvider.email!,
                            );
                            if (mounted) {
                              setState(() {
                                post['has_liked'] = result;
                              });
                            }
                          } catch (e) {
                            if (mounted) {
                              setState(() {
                                post['has_liked'] = hasLiked;
                                post['likes_count'] = (post['likes_count'] ?? 0) + (hasLiked ? 1 : -1);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Failed to update like")),
                              );
                            }
                          }
                        }
                      },
                    ),
                    _buildStatItem(
                      Icons.chat_bubble_outline_rounded,
                      "${post['comments_count'] ?? 0} Comments",
                      onTap: () =>
                          _showCommentsBottomSheet(context, post['id']),
                    ),
                    _buildStatItem(
                      Icons.share_outlined,
                      "Share",
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Theme.of(
                            context,
                          ).scaffoldBackgroundColor,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (context) =>
                              SharePostBottomSheet(post: post),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatTimestamp(String? isoDate) {
    if (isoDate == null) return "Just now";
    try {
      DateTime date = DateTime.parse(isoDate);
      if (!isoDate.endsWith('Z')) {
        date = DateTime.parse('${isoDate}Z');
      }
      final now = DateTime.now();
      final diff = now.difference(date.toLocal());
      if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
      if (diff.inHours < 24) return "${diff.inHours}h ago";
      return "${diff.inDays}d ago";
    } catch (_) {
      return "Recently";
    }
  }

  Widget _buildStatItem(
    IconData icon,
    String label, {
    Color color = Colors.grey,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  void _showCommentsBottomSheet(BuildContext context, int postId) {
    final commentController = TextEditingController();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: isDark
                  ? Theme.of(context).scaffoldBackgroundColor
                  : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text("Comments", style: TextDesign.h3),
                const Divider(),
                Expanded(
                  child: FutureBuilder<List<dynamic>>(
                    future: _postService.getComments(postId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final comments = snapshot.data ?? [];
                      if (comments.isEmpty) {
                        return Center(
                          child: Text(
                            "No comments yet. Be the first!",
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final c = comments[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppColors.secondary
                                      .withValues(alpha: 0.1),
                                  child: const Icon(
                                    Icons.person,
                                    color: AppColors.secondary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.grey[800]
                                          : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              c['user_name'] ?? "User",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              _formatTimestamp(c['created_at']),
                                              style: TextStyle(
                                                color: Colors.grey[500],
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          c['content'] ?? "",
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.white70
                                                : Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          decoration: InputDecoration(
                            hintText: "Add a comment...",
                            filled: true,
                            fillColor: isDark
                                ? Colors.grey[800]
                                : Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () async {
                          if (commentController.text.isNotEmpty &&
                              userProvider.email != null) {
                            try {
                              await _postService.addComment(
                                postId,
                                userProvider.email!,
                                commentController.text,
                              );
                              commentController.clear();
                              setModalState(() {}); // Refresh future builder
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Failed to post comment"),
                                  ),
                                );
                              }
                            }
                          }
                        },
                        icon: const Icon(
                          Icons.send_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(int postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Post?"),
        content: const Text(
          "Are you sure you want to delete this post? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePost(postId);
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)?.translate('no_title') ??
                  "Post Title",
              border: InputBorder.none,
            ),
          ),
          const Divider(),
          TextField(
            controller: _descController,
            maxLines: 6,
            decoration: InputDecoration(
              hintText:
                  AppLocalizations.of(context)?.translate('post_content_hint') ??
                      "Write your description here...",
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaSection(bool isDark) {
    return Row(
      children: [
        _buildMediaButton(
          Icons.image_rounded,
          _selectedImage != null
              ? (AppLocalizations.of(context)?.translate('success') ??
                  "Image Selected")
              : (AppLocalizations.of(context)?.translate('select_image') ??
                  "Add Image"),
          Colors.blue,
          _pickImage,
          (_selectedImage != null || _selectedImageBytes != null),
        ),
      ],
    );
  }

  Widget _buildMediaButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
    bool isSelected,
  ) {
    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.2)
                  : color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? color : color.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: _isUploading
            ? null
            : () async {
                if (_titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter a title")),
                  );
                  return;
                }

                setState(() => _isUploading = true);

                final userProvider = Provider.of<UserProvider>(context, listen: false);
                final email = userProvider.email;

                if (email == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("User session error. Please re-login.")),
                  );
                  setState(() => _isUploading = false);
                  return;
                }

                try {
                  await _postService.createPost(
                    title: _titleController.text.trim(),
                    description: _descController.text.trim(),
                    email: email,
                    image: _selectedImage,
                    bytes: _selectedImageBytes,
                    fileName: _selectedImageName,
                  );

                  if (mounted) {
                    _titleController.clear();
                    _descController.clear();
                    setState(() {
                      _selectedImage = null;
                      _selectedImageBytes = null;
                      _selectedImageName = null;
                      _activeTab = "Posted";
                    });
                    _fetchMyPosts();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Post Shared Successfully!"),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Error: $e"),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                } finally {
                  if (mounted) setState(() => _isUploading = false);
                }
              },
        child: _isUploading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                AppLocalizations.of(context)?.translate('post') ??
                    "Post Update",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
