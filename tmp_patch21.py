import codecs

path = r'c:\src\flutter-apps\edunova_application\lib\student\lecture_detail_page.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

# 1. Update _loadResources to handle Quizzes and Exams properly
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
      } else {
        final response = await _materialService.getResources(
          widget.lecture['id'],
          category: category,
        );
        setState(() => _resources = response);
      }"""

replacement1 = """      final userEmail = Provider.of<UserProvider>(context, listen: false).email;

      if (category == "Assignments") {
        final assignments = await _materialService.getAssignments(widget.lecture['id']);
        setState(() => _resources = assignments);
        
        if (userEmail != null) {
          for (var res in assignments) {
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
      } else if (category == "Quizzes") {
        final quizzes = await _materialService.getQuizzes(widget.lecture['id']);
        setState(() => _resources = quizzes);
        
        if (userEmail != null) {
          for (var res in quizzes) {
            try {
              final sub = await _materialService.getMyQuizSubmission(res['id'], userEmail);
              if (sub != null) {
                // To avoid ID collisions between assignments and quizzes in the local map, 
                // we'll use a prefix if needed, but for now we'll assume separate logic in build
                setState(() => _userSubmissions[res['id']] = sub);
              }
            } catch (e) {
              debugPrint("Error loading quiz sub for ${res['id']}: $e");
            }
          }
        }
      } else if (category == "Exams") {
        if (userEmail != null) {
          final exams = await _materialService.getMyExamMarks(widget.lecture['id'], userEmail);
          setState(() => _resources = exams);
        } else {
          setState(() => _resources = []);
        }
      } else {
        final response = await _materialService.getResources(
          widget.lecture['id'],
          category: category,
        );
        setState(() => _resources = response);
      }"""

# 2. Update _buildResourceList to render Exams as clean ListTiles and handle Quiz submissions
target2 = """    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final resource = _resources[index];
        final isAssignmentOrQuiz = _selectedFilterIndex == 1 || _selectedFilterIndex == 2;
        final isExam = _selectedFilterIndex == 3;
        final submission = isAssignmentOrQuiz ? _userSubmissions[resource['id']] : null;
        
        TextEditingController? controller;
        if (isAssignmentOrQuiz) {
            controller = _controllers.putIfAbsent(resource['id'], () => TextEditingController());
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

replacement2 = """    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final resource = _resources[index];
        final isAssignment = _selectedFilterIndex == 1;
        final isQuiz = _selectedFilterIndex == 2;
        final isExam = _selectedFilterIndex == 3;
        final submission = (isAssignment || isQuiz) ? _userSubmissions[resource['id']] : null;
        
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
                resource['exam_type'] == 'midterm' ? "Midterm Exam" : "Final Exam",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Text(
                "${resource['mark']}%",
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          );
        }

        TextEditingController? controller;
        if (isAssignment || isQuiz) {
            controller = _controllers.putIfAbsent(resource['id'], () => TextEditingController());
            if (submission != null && controller.text.isEmpty) {
              controller.text = submission['solution_text'] ?? "";
            }
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
                          resource['title'] ?? 'No Title',
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
              if (isAssignment || isQuiz) ...["""

# 3. Update Submit Button Logic for Quizzes
target3 = """                    onPressed: () async {
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
                    },"""

replacement3 = """                    onPressed: () async {
                      final email = Provider.of<UserProvider>(context, listen: false).email;
                      if (email != null && controller != null && controller.text.isNotEmpty) {
                        try {
                          if (isQuiz) {
                            await _materialService.submitQuizSolution(
                              quizId: resource['id'],
                              studentEmail: email,
                              solutionText: controller.text,
                            );
                          } else {
                            await _materialService.submitAssignmentSolution(
                              assignmentId: resource['id'],
                              studentEmail: email,
                              solutionText: controller.text,
                            );
                          }
                          _loadContent(); // Refresh
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(isQuiz ? 'Quiz Submitted Successfully' : 'Assignment Submitted Successfully'),
                              backgroundColor: Colors.green,
                            ));
                          }
                        } catch(e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to submit. Check backend connection.')));
                          }
                        }
                      }
                    },"""

text = text.replace(target1, replacement1)
text = text.replace(target2, replacement2)
text = text.replace(target3, replacement3)

with codecs.open(path, 'w', 'utf-8') as f:
    f.write(text)
print("lecture_detail_page.dart patched")
