import 'dart:typed_data';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../l10n/app_localizations.dart';

class AddMaterialDialog extends StatefulWidget {
  final String subjectName;
  final Color subjectColor;
  final List<String> categories;
  final String? forcedCategory;
  final Future<void> Function({
    required String title,
    required String category,
    File? file,
    Uint8List? fileBytes,
    String? fileName,
  })
  onUpload;

  const AddMaterialDialog({
    super.key,
    required this.subjectName,
    required this.subjectColor,
    required this.onUpload,
    this.forcedCategory,
    this.categories = const ["PDFs", "Assignments", "Quizzes", "Exams"],
  });

  @override
  State<AddMaterialDialog> createState() => _AddMaterialDialogState();
}

class _AddMaterialDialogState extends State<AddMaterialDialog> {
  final _titleController = TextEditingController();
  String? _selectedCategory;
  PlatformFile? _selectedPlatformFile;
  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        lockParentWindow: true,
        withData: kIsWeb, // Required for web to get bytes
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedPlatformFile = result.files.first;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Selected: ${_selectedPlatformFile!.name}"),
              backgroundColor: Colors.blueAccent,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        debugPrint("DEBUG: File selected: ${_selectedPlatformFile!.name}");
      } else {
        debugPrint("DEBUG: File selection cancelled");
      }
    } catch (e) {
      debugPrint("DEBUG: Error picking file: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error selecting file: $e")));
      }
    }
  }

  Future<void> _handleUpload() async {
    final title = _titleController.text.trim();
    final category = widget.forcedCategory ?? _selectedCategory;
    if (category == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a category")));
      return;
    }

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a material title")),
      );
      return;
    }
    if (_selectedPlatformFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please upload a file")));
      return;
    }

    setState(() => _isUploading = true);
    try {
      await widget.onUpload(
        title: title,
        category: category,
        file: kIsWeb ? null : File(_selectedPlatformFile!.path!),
        fileBytes: _selectedPlatformFile!.bytes,
        fileName: _selectedPlatformFile!.name,
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Upload failed: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(
        (l10n?.translate('add_material_to') ?? "Add Material to {subject}")
            .replaceAll('{subject}', widget.subjectName),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText:
                    l10n?.translate('material_title') ??
                    (widget.forcedCategory == 'PDFs'
                        ? "PDF Title"
                        : "Material Title"),
              ),
            ),
            if (widget.forcedCategory == null) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: l10n?.translate('category') ?? "Category",
                ),
                value: _selectedCategory,
                items: widget.categories
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _pickFile,
                icon: const Icon(Icons.upload_file_rounded),
                label: Text(
                  _selectedPlatformFile != null
                      ? _selectedPlatformFile!.name
                      : (l10n?.translate('upload_file') ?? "Upload File"),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedPlatformFile != null
                      ? Colors.blueAccent.withOpacity(0.1)
                      : null,
                  foregroundColor: _selectedPlatformFile != null
                      ? Colors.blueAccent
                      : null,
                ),
              ),
            ),
            if (_selectedPlatformFile != null)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "File ready: ${_selectedPlatformFile!.name}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (_isUploading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isUploading ? null : () => Navigator.pop(context),
          child: Text(l10n?.translate('cancel') ?? "Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.subjectColor,
            elevation: 0,
          ),
          onPressed: _isUploading ? null : _handleUpload,
          child: Text(
            l10n?.translate('add') ?? "Add",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
