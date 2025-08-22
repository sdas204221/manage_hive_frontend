import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:manage_hive/repositories/token_repository.dart';
import '../repositories/backup_repository.dart';

class BackupService {
  final BackupRepository backupRepository;
  final TokenRepository tokenRepository;

  BackupService({
    required this.backupRepository,
    required this.tokenRepository,
  });

  Future<Uint8List?> getUserBackup() async {
    String token = (await tokenRepository.getToken())!;
    final backupString = await backupRepository.getUserBackup(token);
    return backupString != null ? Uint8List.fromList(utf8.encode(backupString)) : null;
  }

  Future<Uint8List?> getAdminBackup() async {
    String token = (await tokenRepository.getToken())!;
    final backupString = await backupRepository.getAdminBackup(token);
    return backupString != null ? Uint8List.fromList(utf8.encode(backupString)) : null;
  }

Future<Uint8List?> getSalesCsvBackup() async {
  String token = (await tokenRepository.getToken())!;
  final backupString = await backupRepository.getUserBackup(token);

  if (backupString == null) return null;

  final data = json.decode(backupString);
  final salesLines = data['salesLines'] as List<dynamic>;

  final headers = [
    'transactionId',
    'invoiceNumber',
    'customerName',
    'customerAddress',
    'invoiceIssueDate',
    'paymentMethod',
    'paymentTerms',
    'paymentDate',
    'totalDiscount',
    'description',
    'quantity',
    'unitPrice',
    'tax',
  ];

  final rows = <List<String>>[headers];

  for (final line in salesLines) {
    final invoice = line['invoice'];
    rows.add([
      line['sid'].toString(),
      invoice['invoiceNumber'].toString(),
      invoice['customerName'] ?? '',
      invoice['customerAddress'] ?? '',
invoice['issueDate'] == null
    ? ''
    : DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.parse(invoice['issueDate']).toLocal()),
      invoice['paymentMethod'] ?? '',
      invoice['paymentTerms'] ?? '',
      invoice['paymentDate'] == null
    ? ''
    : DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.parse(invoice['paymentDate']).toLocal()),
      invoice['discount'].toString(),
      line['description'] ?? '',
      line['quantity'].toString(),
      line['unitPrice'].toString(),
      line['tax'].toString(),
    ]);
  }

  final csvBuffer = StringBuffer();
  for (final row in rows) {
    csvBuffer.writeln(row.map((e) => '"${e.replaceAll('"', '""')}"').join(','));
  }

  return Uint8List.fromList(utf8.encode(csvBuffer.toString()));
}

}
