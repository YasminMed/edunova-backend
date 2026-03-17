import codecs

path = r'c:\src\flutter-apps\edunova_application\lib\lecturer\managed_subject_detail.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

target = """                        onPressed: () {
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
                        },"""

replacement = """                        onPressed: () {
                          // Navigate to review submissions page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AssignmentReviewPage(
                                assignment: resource,
                                viewModel: viewModel,
                                color: color,
                                isQuiz: isQuiz,
                              ),
                            ),
                          );
                        },"""

text = text.replace(target, replacement)

with codecs.open(path, 'w', 'utf-8') as f:
    f.write(text)
print("ManagedSubjectDetail updated to pass isQuiz to ReviewPage")
