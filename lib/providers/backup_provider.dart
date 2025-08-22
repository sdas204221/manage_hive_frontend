import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/backup_service.dart';

class BackupProvider extends ChangeNotifier {
  final BackupService backupService;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  BackupProvider({required this.backupService});

  Future<Uint8List?> getUserBackup() async {
    _errorMessage = null;
    notifyListeners();
    Uint8List? backupBytes;
    try {
      backupBytes = await backupService.getUserBackup();
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
    return backupBytes;
  }
  Future<Uint8List?> getSalesCsvBackup() async {
  _errorMessage = null;
  notifyListeners();

  Uint8List? csvBytes;
  try {
    csvBytes = await backupService.getSalesCsvBackup();
  } catch (e) {
    _errorMessage = e.toString();
  }

  notifyListeners();
  return csvBytes;
}


  Future<Uint8List?> getAdminBackup() async {
    _errorMessage = null;
    notifyListeners();
    Uint8List? backupBytes;
    try {
      backupBytes = await backupService.getAdminBackup();
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
    return backupBytes;
  }
}
