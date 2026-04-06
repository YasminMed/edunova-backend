import codecs

path = r'c:\src\flutter-apps\edunova_application\lib\student\lecture_detail_page.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

target1 = """      if (category == "Assignments") {
        final assignments = await _materialService.getAssignments(widget.lecture['id']);
        setState(() => _resources = assignments);
        
        final userEmail = Provider.of<UserProvider>(context, listen: false).email;
        if (userEmail != null) {
          for (var assignment in assignments) {
            try {
              final sub = await _materialService.getMySubmission(assignment['id'], userEmail);
              if (sub != null) {
                setState(() => _userSubmissions[assignment['id']] = sub);
              }
            } catch (e) {
              debugPrint("Error loading submission for ${assignment['id']}: $e");
            }
          }
        }
      } else {"""

replacement1 = """      if (category == "Assignments" || category == "Quizzes") {
        final List<dynamic> fetchedResources = category == "Assignments" 
            ? await _materialService.getAssignments(widget.lecture['id'])
            : await _materialService.getQuizzes(widget.lecture['id']);
        setState(() => _resources = fetchedResources);
        
        final userEmail = Provider.of<UserProvider>(context, listen: false).email;
        if (userEmail != null) {
          for (var res in fetchedResources) {
            try {
              final sub = await _materialService.getMySubmission(res['id'], userEmail);
              if (sub != null) {
                setState(() => _userSubmissions[res['id']] = sub);
              }
            } catch (e) {
              debugPrint("Error loading submission for ${res['id']}: $e");
            }
          }
        }
      } else if (category == "Exams") {
        final userEmail = Provider.of<UserProvider>(context, listen: false).email;
        if (userEmail != null) {
          final examMarks = await _materialService.getMyExamMarks(widget.lecture['id'], userEmail);
          setState(() => _resources = examMarks);
        } else {
          setState(() => _resources = []);
        }
      } else {"""

target2 = """          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                        Text(
                          resource['created_at'] != null
                            ? "Shared on ${resource['created_at'].toString().split('T')[0]}"
                            : "Shared recently",
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (submission != null && submission['is_graded'])
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Grade: ${submission['grade']}",
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    )
                  else if (submission != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Uploaded",
                        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                ],
              ),
              if (isAssignmentOrQuiz) ...["""

replacement2 = """          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isExam) ...[
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.grade_rounded, color: color),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            resource['exam_type'] == 'midterm' ? 'Mid-Term Exam' : 'Final Exam',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark ? Colors.white : AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Mark: ${resource['mark']}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else ...[
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
                            resource['title'] ?? 'Resource',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.primaryText,
                            ),
                          ),
                          Text(
                            resource['created_at'] != null
                              ? "Shared on ${resource['created_at'].toString().split('T')[0]}"
                              : "Shared recently",
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white54 : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (submission != null && (submission['is_graded'] == true || submission['is_graded'] == 1))
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Grade: ${submission['grade']}",
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      )
                    else if (submission != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Uploaded",
                          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ],
              if (isAssignmentOrQuiz) ...["""

def apply_patch(text, target, curr_repl):
    if target in text:
        return text.replace(target, curr_repl)
    elif target.replace('\\n', '\\r\\n') in text:
        return text.replace(target.replace('\\n', '\\r\\n'), curr_repl.replace('\\n', '\\r\\n'))
    else:
        print("WARNING: Target not found:\\n" + target[:100] + "...")
        return text

text = apply_patch(text, target1, replacement1)
text = apply_patch(text, target2, replacement2)

with codecs.open(path, 'w', 'utf-8') as f:
    f.write(text)
print("LectureDetailPage patched successfully.")
