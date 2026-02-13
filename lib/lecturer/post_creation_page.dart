import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';

class PostCreationPage extends StatefulWidget {
  const PostCreationPage({super.key});

  @override
  State<PostCreationPage> createState() => _PostCreationPageState();
}

class _PostCreationPageState extends State<PostCreationPage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.primaryText;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Create Post",
          style: TextDesign.h2.copyWith(color: textColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInputCard(isDark),
            const SizedBox(height: 24),
            _buildMediaSection(isDark),
            const SizedBox(height: 40),
            _buildPostButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              hintText: "Post Title",
              border: InputBorder.none,
            ),
          ),
          const Divider(),
          TextField(
            controller: _descController,
            maxLines: 8,
            decoration: const InputDecoration(
              hintText: "Write your description here...",
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
        _buildMediaButton(Icons.image_rounded, "Add Image", Colors.blue),
        const SizedBox(width: 16),
        _buildMediaButton(Icons.videocam_rounded, "Add Video", Colors.purple),
      ],
    );
  }

  Widget _buildMediaButton(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () {
          setState(() => _isUploading = true);
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Post Shared Successfully!")),
              );
            }
          });
        },
        child: _isUploading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "Post Update",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
