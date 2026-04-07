import codecs

path = r'c:\src\flutter-apps\edunova_application\lib\student\lecture_detail_page.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

target = "  Map<int, dynamic> _userSubmissions = {};\n  bool _isLoading = true;"
replacement = "  Map<int, dynamic> _userSubmissions = {};\n  Set<int> _activeEditStates = {};\n  bool _isLoading = true;"

text = text.replace(target, replacement)
# also correct the line endings if it was using windows line endings
target_windows = "  Map<int, dynamic> _userSubmissions = {};\r\n  bool _isLoading = true;"
replacement_windows = "  Map<int, dynamic> _userSubmissions = {};\r\n  Set<int> _activeEditStates = {};\r\n  bool _isLoading = true;"
text = text.replace(target_windows, replacement_windows)

with codecs.open(path, 'w', 'utf-8') as f:
    f.write(text)

print("Path updated")
