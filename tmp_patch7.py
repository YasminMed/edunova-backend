import codecs

path = r'c:\src\flutter-apps\edunova_application\lib\student\lecture_detail_page.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

# Replacement 1: _loadResources 
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
          for (var resource in fetchedResources) {
            try {
              final sub = await _materialService.getMySubmission(resource['id'], userEmail);
              if (sub != null) {
                setState(() => _userSubmissions[resource['id']] = sub);
              }
            } catch (e) {
              debugPrint("Error loading submission for ${resource['id']}: $e");
            }
          }
        }
      } else if (category == "Exams") {
          final userEmail = Provider.of<UserProvider>(context, listen: false).email;
          if (userEmail != null) {
              final marks = await _materialService.getMyExamMarks(widget.lecture['id'], userEmail);
              setState(() => _resources = marks);
          }
      } else {"""

# Replacement 2: _buildResourceList declaration
target2 = """      delegate: SliverChildBuilderDelegate((context, index) {
        final resource = _resources[index];
        final isAssignment = _selectedFilterIndex == 1;
        final submission = isAssignment ? _userSubmissions[resource['id']] : null;"""

replacement2 = """      delegate: SliverChildBuilderDelegate((context, index) {
        final resource = _resources[index];
        final isAssignmentOrQuiz = _selectedFilterIndex == 1 || _selectedFilterIndex == 2;
        final isExam = _selectedFilterIndex == 3;
        final submission = isAssignmentOrQuiz ? _userSubmissions[resource['id']] : null;
        
        if (isExam) {
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
                child: Row(
                    children: [
                        Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.stars_rounded, color: color),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                            child: Text(
                                resource['exam_type'] == 'midterm' ? 'Mid-Term Exam' : 'Final Exam',
                                style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.primaryText, fontSize: 16),
                            ),
                        ),
                        Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                                "${resource['mark']}",
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16),
                            ),
                        ),
                    ],
                )
            );
        }
"""

# Replacement 3: isAssignment checks down in the builder
target3 = """              if (isAssignment) ...[
                const SizedBox(height: 12),"""

replacement3 = """              if (isAssignmentOrQuiz) ...[
                const SizedBox(height: 12),"""

# Let's apply them one by one
def apply_patch(text, target, curr_repl):
    target_win = target.replace('\\n', '\\r\\n')
    repl_win = curr_repl.replace('\\n', '\\r\\n')
    if target in text:
        return text.replace(target, curr_repl)
    elif target_win in text:
        return text.replace(target_win, repl_win)
    else:
        print("WARNING: Target not found:\n" + target[:100] + "...")
        return text

text = apply_patch(text, target1, replacement1)
text = apply_patch(text, target2, replacement2)
text = apply_patch(text, target3, replacement3)

with codecs.open(path, 'w', 'utf-8') as f:
    f.write(text)
