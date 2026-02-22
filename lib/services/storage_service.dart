import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'database_service.dart';

final storageServiceProvider = Provider<StorageService>(
  (ref) => StorageService(ref),
);

class StorageService {
  final Ref ref;

  StorageService(this.ref);

  Future<void> exportData() async {
    final dbService = ref.read(databaseServiceProvider);

    final exportData = await dbService.exportToJson();
    final jsonString = jsonEncode(exportData);

    // Save logic based on platform
    if (Platform.isWindows) {
      String? result = await FilePicker.platform.saveFile(
        dialogTitle: 'Please select an output file:',
        fileName: 'digital_saving_box_backup.json',
      );

      if (result != null) {
        final file = File(result);
        await file.writeAsString(jsonString);
      }
    } else {
      // Mobile - save to temp and share
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/digital_saving_box_backup.json');
      await file.writeAsString(jsonString);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: 'My Digital Saving Data'),
      );
    }
  }

  Future<void> importData() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(content);

      final dbService = ref.read(databaseServiceProvider);
      await dbService.importFromJson(data);
    }
  }
}
