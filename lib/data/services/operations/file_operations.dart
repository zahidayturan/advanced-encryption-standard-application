import 'dart:typed_data';
import 'package:aes/data/firebase/firebase_firestore_helper.dart';
import 'package:aes/data/firebase/firebase_storage_helper.dart';
import 'package:aes/data/models/dto/key_file.dart';
import 'package:aes/data/models/file_info.dart';
import 'package:aes/data/services/file_service.dart';

class FileOperations implements FileService {

  @override
  Future<List<KeyFileInfo>?> getAllFileInfo() async {
    var files = await FirebaseFirestoreOperation().getAllFileInfo();
    return files;
  }

  @override
  Future<void> insertFileInfo(FileInfo fileInfo,Uint8List encryptedBytes) async {
    await FirebaseStorageOperation().uploadFileToFirebase(fileInfo, encryptedBytes);
  }

}