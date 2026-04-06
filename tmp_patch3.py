import codecs

path = r'c:\src\flutter-apps\edunova_application\lib\student\lecture_detail_page.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    lines = f.readlines()

start_idx = -1
for i, line in enumerate(lines):
    if "if (isAssignment) ...[" in line:
        start_idx = i
        break

if start_idx != -1:
    end_idx = start_idx + 82 # 82 is roughly the number of lines down to the end of the isAssignment block based on previous views
    # Let's dynamically find the end instead
    bracket_count = 0
    in_block = False
    for i in range(start_idx, len(lines)):
        if "if (isAssignment) ...[" in lines[i]:
            in_block = True
        
        if in_block:
            bracket_count += lines[i].count('[')
            bracket_count -= lines[i].count(']')
            if bracket_count == 0:
                end_idx = i + 1
                break

    new_content = """              if (isAssignment) ...[
                const SizedBox(height: 12),
                Text(
                  resource['content'] ?? "",
                  style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.grey[700]),
                ),
                if (resource['file_url'] != null) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {},
                    child: Row(
                      children: [
                        Icon(Icons.attach_file_rounded, size: 14, color: color),
                        const SizedBox(width: 4),
                        const Text("Reference Material", style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                
                // If submitted and not actively editing, show 'Uploaded' and 'Edit' button
                if (submission != null && !_activeEditStates.contains(resource['id'])) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.cloud_done_rounded, color: Colors.orange, size: 24),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Answer Uploaded", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text(
                                  "Tap edit to modify your submission", 
                                  style: TextStyle(color: isDark ? Colors.white54 : Colors.grey, fontSize: 12)
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (!(submission['is_graded'] == true || submission['is_graded'] == 1))
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
                            onPressed: () {
                              setState(() {
                                _activeEditStates.add(resource['id']);
                              });
                            },
                          ),
                      ],
                    ),
                  )
                ] else ...[
                  // Edit / Upload Box Mode
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
                  Row(
                    children: [
                      if (submission != null) ...[
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _activeEditStates.remove(resource['id']);
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Cancel"),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
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
                                setState(() {
                                  _activeEditStates.remove(resource['id']);
                                });
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
                          child: Text(submission != null ? "Save Changes" : "Submit Answer"),
                        ),
                      ),
                    ],
                  ),
                ],
                
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
                            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 24),
                            const SizedBox(width: 8),
                            const Text("Lecturer Feedback", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "${submission['grade']}",
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            )
                          ],
                        ),
                        if (submission['lecturer_note'] != null && submission['lecturer_note'].toString().isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[800] : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.format_quote_rounded, color: Colors.green.withOpacity(0.5), size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "${submission['lecturer_note']}",
                                    style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontStyle: FontStyle.italic),
                                  ),
                                ),
                              ],
                            ),
                          )
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
