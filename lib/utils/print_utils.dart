import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'dart:io';

Future<void> startPrinting(Uint8List pdfBytes) async {
if (kIsWeb) {
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdfBytes,
  );
} else if (Platform.isAndroid || Platform.isIOS || Platform.isWindows || Platform.isMacOS) {
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdfBytes,
  );
} else if (Platform.isLinux) {
  if (kDebugMode) {
    print('Printing not supported on Linux (yet).');
  }
} else {
  if (kDebugMode) {
    print('Unsupported platform');
  }
}

}