import codecs

path = r'c:\src\flutter-apps\edunova_application\lib\student\lecture_detail_page.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    lines = f.readlines()

start_idx = -1
for i, line in enumerate(lines):
    if "if (submission != null && submission['is_graded']) ...[" in line:
        start_idx = i
        break

if start_idx != -1:
    end_idx = start_idx + 23
    new_content = """                TextField(
                  controller: controller,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "Your answer here...",
                    filled: true,
                    fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final email = Provider.of<UserProvider>(context, listen: false).email;
                      if (email != null && controller != null && controller.text.isNotEmpty) {
                        try {
                          await _materialService.submitAssignmentSolution(
                            assignmentId: resource['id'],
                            studentEmail: email,
                            solutionText: controller.text,
                          );
                          _loadContent(); // Refresh
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Assignment Submitted Successfully'), backgroundColor: Colors.green));
                          }
                        } catch(e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to submit assignment. Check backend connection.')));
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: submission != null ? Colors.orange : color,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(submission != null ? "Edit Submission" : "Submit Answer"),
                  ),
                ),
                if (submission != null && (submission['is_graded'] == True || submission['is_graded'] == 1)) ...[
                  const Divider(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            Text("Lecturer Feedback", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
                          ],
                        ),
                        if (submission['lecturer_note'] != null && submission['lecturer_note'].toString().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            "Grade: ${submission['grade']} - Note: ${submission['lecturer_note']}",
                            style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                          ),
                        ]
                      ],
                    ),
                  ),
                ]
              ],
"""
    lines[start_idx:end_idx] = [new_content]

with codecs.open(path, 'w', 'utf-8') as f:
    f.writelines(lines)

print("Replaced!")
