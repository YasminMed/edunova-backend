import codecs

path = r'c:\src\flutter-apps\edunova_application\lib\viewmodels\lecturer\managed_subject_viewmodel.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

target = """    } finally {
      setBusy(false);
    }
  }

  List<dynamic> _submissions = [];"""

target_windows = target.replace('\n', '\r\n')

replacement = """    } finally {
      setBusy(false);
    }
  }

  Future<void> loadQuizzes(int courseId) async {
    setBusy(true);
    try {
      _resources = await _materialService.getQuizzes(courseId);
    } catch (e) {
      debugPrint("Error loading quizzes: $e");
    } finally {
      setBusy(false);
    }
  }

  Future<void> addQuiz({
    required int courseId,
    required String title,
    required String content,
    File? file,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    setBusy(true);
    try {
      await _materialService.createQuiz(
        courseId: courseId,
        title: title,
        content: content,
        file: file,
        fileBytes: fileBytes,
        fileName: fileName,
      );
      await loadQuizzes(courseId);
    } catch (e) {
      debugPrint("Error creating quiz: $e");
    } finally {
      setBusy(false);
    }
  }

  List<dynamic> _submissions = [];"""

replacement_windows = replacement.replace('\n', '\r\n')

if target in text:
    text = text.replace(target, replacement)
    print("Replaced Unix line endings")
elif target_windows in text:
    text = text.replace(target_windows, replacement_windows)
    print("Replaced Windows line endings")
else:
    print("WARNING: Target block not found.")

with codecs.open(path, 'w', 'utf-8') as f:
    f.write(text)
