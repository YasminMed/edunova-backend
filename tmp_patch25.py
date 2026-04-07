import codecs

path = r'c:\src\flutter-apps\edunova_application\lib\student\lecture_detail_page.dart'

try:
    with codecs.open(path, 'r', 'utf-8') as f:
        text = f.read()
    encoding = 'utf-8'
except UnicodeDecodeError:
    with codecs.open(path, 'r', 'utf-16le') as f:
        text = f.read()
    encoding = 'utf-16le'

# Fix 1: Update _loadResources to handle Quizzes separately for Student
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
        final bool isQuiz = category == "Quizzes";
        final items = isQuiz 
            ? await _materialService.getQuizzes(widget.lecture['id'])
            : await _materialService.getAssignments(widget.lecture['id']);
            
        setState(() => _resources = items);
        
        final userEmail = Provider.of<UserProvider>(context, listen: false).email;
        if (userEmail != null) {
          for (var item in items) {
            try {
              final sub = isQuiz
                  ? await _materialService.getMyQuizSubmission(item['id'], userEmail)
                  : await _materialService.getMySubmission(item['id'], userEmail);
              if (sub != null) {
                setState(() => _userSubmissions[item['id']] = sub);
              }
            } catch (e) {
              debugPrint("Error loading submission for ${item['id']}: $e");
            }
          }
        }
      } else {"""

# Fix 2: Define isQuiz in build list
target2 = """        final resource = _resources[index];
        final isAssignmentOrQuiz = _selectedFilterIndex == 1 || _selectedFilterIndex == 2;
        final isExam = _selectedFilterIndex == 3;"""

replacement2 = """        final resource = _resources[index];
        final isAssignmentOrQuiz = _selectedFilterIndex == 1 || _selectedFilterIndex == 2;
        final isQuiz = _selectedFilterIndex == 2;
        final isExam = _selectedFilterIndex == 3;"""

# Fix 3: Fix boolean check for is_graded in build list
target3 = """                  if (submission != null && submission['is_graded'])"""
replacement3 = """                  if (submission != null && (submission['is_graded'] == true || submission['is_graded'] == 1))"""

text = text.replace(target1, replacement1)
text = text.replace(target2, replacement2)
text = text.replace(target3, replacement3)

with codecs.open(path, 'w', encoding) as f:
    f.write(text)
print(f"LectureDetailPage fixed using {encoding}")
