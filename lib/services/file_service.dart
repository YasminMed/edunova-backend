import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'auth_service.dart';

class FileService {
  static final Dio _dio = Dio();

  /// Downloads a file to local storage and opens it using native viewer.
  /// falls back to launchUrlString on Web.
  static Future<void> downloadAndOpenFile(BuildContext context, String? url, String fileName) async {
    if (url == null || url.isEmpty) {
      _showError(context, "File URL is missing.");
      return;
    }

    final resolvedUrl = AuthService.resolveUrl(url);

    if (kIsWeb) {
      await launchUrlString(resolvedUrl, mode: LaunchMode.externalApplication);
      return;
    }

    try {
      // 1. Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              const SizedBox(width: 15),
              Text("Opening ${fileName}..."),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // 2. Prepare local path
      final tempDir = await getTemporaryDirectory();
      final savePath = "${tempDir.path}/$fileName";

      // 3. Download the file
      await _dio.download(resolvedUrl, savePath);

      // 4. Open it
      final result = await OpenFilex.open(savePath);
      
      if (result.type != ResultType.done) {
        throw Exception(result.message);
      }
    } catch (e) {
      debugPrint("Error viewing file: $e");
      _showError(context, "Could not open file: $e");
    }
  }

  static void _showError(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}
