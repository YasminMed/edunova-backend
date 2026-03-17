import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../viewmodels/lecturer/managed_subject_viewmodel.dart';

class AssignmentReviewPage extends StatefulWidget {
  final Map<String, dynamic> assignment;
  final ManagedSubjectViewModel viewModel;
  final Color color;
  final bool isQuiz;

  const AssignmentReviewPage({
    super.key,
    required this.assignment,
    required this.viewModel,
    required this.color,
    this.isQuiz = false,
  });

  @override
  State<AssignmentReviewPage> createState() => _AssignmentReviewPageState();
}

class _AssignmentReviewPageState extends State<AssignmentReviewPage> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadSubmissions(widget.assignment['id'], isQuiz: widget.isQuiz);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.assignment['title'], style: TextDesign.h3.copyWith(color: Colors.white)),
        backgroundColor: widget.color,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          if (widget.viewModel.isBusy) {
            return const Center(child: CircularProgressIndicator());
          }

          if (widget.viewModel.submissions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline_rounded, size: 64, color: widget.color.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  const Text("No submissions yet."),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: widget.viewModel.submissions.length,
            itemBuilder: (context, index) {
              final sub = widget.viewModel.submissions[index];
              return _buildSubmissionCard(context, sub, isDark);
            },
          );
        },
      ),
    );
  }

  Widget _buildSubmissionCard(BuildContext context, Map<String, dynamic> sub, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sub['student_name'],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              if (sub['is_graded'])
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Grade: ${sub['grade']}",
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Ungraded",
                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            sub['solution_text'] ?? "No text response.",
            style: TextStyle(color: isDark ? Colors.white70 : Colors.grey[700]),
          ),
          if (sub['file_url'] != null) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                // Download file logic
              },
              child: Row(
                children: [
                  Icon(Icons.attach_file_rounded, size: 16, color: widget.color),
                  const SizedBox(width: 4),
                  const Text("View Attachment", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showGradeDialog(context, sub),
              style: ElevatedButton.styleFrom(
                backgroundColor: sub['is_graded'] ? widget.color.withOpacity(0.1) : widget.color,
                foregroundColor: sub['is_graded'] ? widget.color : Colors.white,
                elevation: 0,
              ),
              child: Text(sub['is_graded'] ? "Edit Grade" : "Grade Now"),
            ),
          ),
          if (sub['is_graded']) ...[
            const Divider(height: 24),
            Text(
              "Note: ${sub['lecturer_note'] ?? 'No note provided.'}",
              style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  void _showGradeDialog(BuildContext context, Map<String, dynamic> sub) {
    final gradeController = TextEditingController(text: sub['is_graded'] ? sub['grade'].toString() : "");
    final noteController = TextEditingController(text: sub['is_graded'] && sub['lecturer_note'] != null ? sub['lecturer_note'].toString() : "");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Grade ${sub['student_name']}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: gradeController,
              decoration: const InputDecoration(labelText: "Grade (e.g. A, 90/100)"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: "Notes/Feedback"),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (gradeController.text.isNotEmpty) {
                await widget.viewModel.gradeSubmission(
                  submissionId: sub['id'],
                  grade: gradeController.text,
                  note: noteController.text,
                  parentId: widget.assignment['id'],
                  isQuiz: widget.isQuiz,
                );
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text("Submit Grade"),
          ),
        ],
      ),
    );
  }
}
