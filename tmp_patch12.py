import codecs

path = r'c:\src\flutter-apps\edunova_application\lib\student\lecture_detail_page.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

target1 = """  Set<int> _activeEditStates = {};
  bool _isLoading = true;

  @override
  void initState() {"""

replacement1 = """  Set<int> _activeEditStates = {};
  bool _isLoading = true;
  final Map<int, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      if (controller != null) controller.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {"""

target2 = """    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final resource = _resources[index];
        final isAssignment = _selectedFilterIndex == 1;
        final submission = isAssignment ? _userSubmissions[resource['id']] : null;"""

replacement2 = """    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final resource = _resources[index];
        final isAssignmentOrQuiz = _selectedFilterIndex == 1 || _selectedFilterIndex == 2;
        final isExam = _selectedFilterIndex == 3;
        final submission = isAssignmentOrQuiz ? _userSubmissions[resource['id']] : null;
        
        TextEditingController? controller;
        if (isAssignmentOrQuiz) {
            controller = _controllers.putIfAbsent(resource['id'], () => TextEditingController());
        }"""

# Fix `if (isAssignment) ...[` on line 492
target3 = """              if (isAssignment) ...[
                const SizedBox(height: 12),"""

replacement3 = """              if (isAssignmentOrQuiz) ...[
                const SizedBox(height: 12),"""

def apply_patch(text, target, curr_repl):
    target_win = target.replace('\n', '\r\n')
    repl_win = curr_repl.replace('\n', '\r\n')
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
print("Patch applied to dart file")
