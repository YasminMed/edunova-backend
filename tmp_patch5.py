import codecs

path = r'c:\src\flutter-apps\edunova_application\lib\student\lecture_detail_page.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

target = """                        if (!(submission['is_graded'] == true || submission['is_graded'] == 1))
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
                            onPressed: () {
                              setState(() {
                                _activeEditStates.add(resource['id']);
                              });
                            },
                          ),"""

target_windows = target.replace('\n', '\r\n')

replacement = """                        IconButton(
                          icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
                          onPressed: () {
                            setState(() {
                              _activeEditStates.add(resource['id']);
                            });
                          },
                        ),"""

replacement_windows = replacement.replace('\n', '\r\n')

if target in text:
    text = text.replace(target, replacement)
    print("Replaced Unix line endings")
elif target_windows in text:
    text = text.replace(target_windows, replacement_windows)
    print("Replaced Windows line endings")
else:
    print("WARNING: Target block not found. Make sure the text matches exactly.")

with codecs.open(path, 'w', 'utf-8') as f:
    f.write(text)
