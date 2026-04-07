import codecs
import re

path = r'c:\src\flutter-apps\edunova_application\lib\lecturer\managed_subject_detail.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

# 1. Update _buildResourceList to handle Exams
target1 = """    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 100),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == resources.length) {
              return _buildAddButton(context, categoryName, color, viewModel);
            }

            final resource = resources[index];
            final isAssignment = viewModel.selectedFilterIndex == 1;

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
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: color),
                      ),
                      const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        resource['title'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : AppColors.primaryText,
                                        ),
                                      ),
                                      if (resource['file_url'] != null)
                                        Text(
                                          "File: ${resource['file_url'].split('/').last}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: color.withOpacity(0.8),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      Text(
                                        resource['created_at'] != null 
                                          ? "Uploaded on ${resource['created_at'].toString().split('T')[0]}"
                                          : "Shared recently",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark ? Colors.white54 : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.redAccent,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                    if (isAssignment && resource['content'] != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        resource['content'],
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.grey[700],
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color.withOpacity(0.1),
                          foregroundColor: color,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // Navigate to review submissions page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AssignmentReviewPage(
                                assignment: resource,
                                viewModel: viewModel,
                                color: color,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.people_outline_rounded, size: 18),
                        label: const Text("View Submissions"),
                      ),
                    ),
                ],
              ),
            );
          },
          childCount: resources.length + 1,
        ),
      ),
    );"""

replacement1 = """    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 100),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == resources.length) {
              return _buildAddButton(context, categoryName, color, viewModel);
            }

            final resource = resources[index];
            final isAssignment = viewModel.selectedFilterIndex == 1;
            final isQuiz = viewModel.selectedFilterIndex == 2;
            final isExam = viewModel.selectedFilterIndex == 3;

            if (isExam) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withOpacity(0.1),
                    child: Icon(Icons.school_rounded, color: color, size: 20),
                  ),
                  title: Text(
                    resource['student_name'] ?? 'Unknown Student',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    resource['exam_type'] == 'midterm' ? "Mid-Term Exam" : "Final Exam",
                    style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${resource['mark']}%",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.edit_rounded, size: 20),
                        onPressed: () {
                          _showEditExamMarkDialog(context, viewModel, resource['id'], resource['mark']);
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

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
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: color),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              resource['title'] ?? 'No Title',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.primaryText,
                              ),
                            ),
                            if (resource['file_url'] != null)
                              Text(
                                "File: ${resource['file_url'].split('/').last}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: color.withOpacity(0.8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            Text(
                              resource['created_at'] != null 
                                ? "Uploaded on ${resource['created_at'].toString().split('T')[0]}"
                                : "Shared recently",
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white54 : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.redAccent,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  if ((isAssignment || isQuiz) && resource['content'] != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      resource['content'],
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.grey[700],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color.withOpacity(0.1),
                        foregroundColor: color,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        // Navigate to review submissions page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AssignmentReviewPage(
                              assignment: resource,
                              viewModel: viewModel,
                              color: color,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.people_outline_rounded, size: 18),
                      label: const Text("View Submissions"),
                    ),
                  ),
                ],
              ),
            );
          },
          childCount: resources.length + 1,
        ),
      ),
    );"""

# 2. Update _buildAddButton to handle Exams
target2 = """          onTap: () {
          if (categoryName == "Assignments") {
            _showAddAssignmentDialog(context, viewModel, subject['id']);
          } else if (categoryName == "Quizzes") {
            _showAddQuizDialog(context, viewModel, subject['id']);
          } else if (categoryName == "PDFs") {
            _showAddMaterialDialog(context, viewModel, subject['id'], forcedCategory: 'PDFs');
          } else {
            _showAddMaterialDialog(context, viewModel, subject['id']);
          }
          },"""

replacement2 = """          onTap: () {
          if (categoryName == "Assignments") {
            _showAddAssignmentDialog(context, viewModel, subject['id']);
          } else if (categoryName == "Quizzes") {
            _showAddQuizDialog(context, viewModel, subject['id']);
          } else if (categoryName == "Exams") {
            _showAddExamMarkDialog(context, viewModel, subject['id']);
          } else if (categoryName == "PDFs") {
            _showAddMaterialDialog(context, viewModel, subject['id'], forcedCategory: 'PDFs');
          } else {
            _showAddMaterialDialog(context, viewModel, subject['id']);
          }
          },"""

# 3. Add Exam Dialogs
target3 = """  void _showAddQuizDialog(
    BuildContext context,
    ManagedSubjectViewModel viewModel,
    int courseId,
  ) {"""

replacement3 = """  void _showAddExamMarkDialog(
    BuildContext context,
    ManagedSubjectViewModel viewModel,
    int courseId,
  ) {
    dynamic selectedStudent;
    String examType = 'midterm';
    final markController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Add Exam Mark"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<dynamic>(
                value: selectedStudent,
                hint: const Text("Select Student"),
                items: viewModel.studentsList.map((s) {
                  return DropdownMenuItem(
                    value: s,
                    child: Text(s['full_name'] ?? s['email']),
                  );
                }).toList(),
                onChanged: (val) => setState(() => selectedStudent = val),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: examType,
                decoration: const InputDecoration(labelText: "Exam Type"),
                items: const [
                  DropdownMenuItem(value: 'midterm', child: Text("Mid-Term Exam")),
                  DropdownMenuItem(value: 'final', child: Text("Final Exam")),
                ],
                onChanged: (val) => setState(() => examType = val!),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: markController,
                decoration: const InputDecoration(labelText: "Mark (%)", suffixText: "%"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                if (selectedStudent != null && markController.text.isNotEmpty) {
                  viewModel.addExamMark(
                    courseId: courseId,
                    studentId: selectedStudent['id'],
                    examType: examType,
                    mark: markController.text,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text("Upload"),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditExamMarkDialog(
    BuildContext context,
    ManagedSubjectViewModel viewModel,
    int markId,
    String currentMark,
  ) {
    final markController = TextEditingController(text: currentMark);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Exam Mark"),
        content: TextField(
          controller: markController,
          decoration: const InputDecoration(labelText: "Mark (%)", suffixText: "%"),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (markController.text.isNotEmpty) {
                viewModel.updateExamMark(
                  courseId: subject['id'],
                  markId: markId,
                  mark: markController.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showAddQuizDialog(
    BuildContext context,
    ManagedSubjectViewModel viewModel,
    int courseId,
  ) {"""

text = text.replace(target1, replacement1)
text = text.replace(target2, replacement2)
text = text.replace(target3, replacement3)

with codecs.open(path, 'w', 'utf-8') as f:
    f.write(text)
print("managed_subject_detail.dart patched")
