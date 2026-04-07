import re
import codecs

filepath = r'c:\src\flutter-apps\edunova_application\lib\student\lecture_detail_page.dart'

with codecs.open(filepath, 'r', 'utf-8') as f:
    text = f.read()

# 1. Replace the button block
pattern1 = r'const SizedBox\(height: 12\);\s*SizedBox\(\s*width: double\.infinity,\s*child: ElevatedButton\(\s*onPressed: \(\) => _showSolveAssignmentDialog\(context, resource, submission\),.*?child: Text\(submission != null \? "Edit Submission" : "Solve Assignment"\),\s*\),\s*\),'

replacement1 = """const SizedBox(height: 16);
                TextField(
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
                if (submission != null && (submission['is_graded'] == true || submission['is_graded'] == 1)) ...[
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
                        if (submission['lecturer_note'] != null && str(submission['lecturer_note']) != "") ...[
                          const SizedBox(height: 8),
                          Text(
                            "Grade: ${submission['grade']} - Note: ${submission['lecturer_note']}",
                            style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                          ),
                        ]
                      ],
                    ),
                  ),
                ]"""


text = re.sub(pattern1, replacement1, text, flags=re.DOTALL)

# 2. Remove _showSolveAssignmentDialog
pattern2 = r'void _showSolveAssignmentDialog.*?^}$'
text = re.sub(pattern2, '', text, flags=re.MULTILINE|re.DOTALL)

with codecs.open(filepath, 'w', 'utf-8') as f:
    f.write(text)

print("Patch applied")
