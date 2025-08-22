// invoice_downloader_io.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> download(Uint8List bytes, String filename) async {
  if (Platform.isAndroid) {
    final status = await Permission.storage.request();
    if (!status.isGranted) throw Exception('Permission denied');
  }

  final dir = await getApplicationDocumentsDirectory();
  final folder = Directory('${dir.path}/manage_hive');
  if (!(await folder.exists())) await folder.create(recursive: true);

  final file = File('${folder.path}/$filename');
  await file.writeAsBytes(bytes);
}
