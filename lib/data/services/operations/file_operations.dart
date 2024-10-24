import 'package:aes/data/firestore/firebase_firestore_helper.dart';
import 'package:aes/data/models/file_info.dart';
import 'package:aes/data/services/file_service.dart';

class FileOperations implements FileService {

  @override
  Future<List<FileInfo>?> getAllFileInfo() async {
    var files = await FirebaseFirestoreOperation().getAllFileInfo();
    return files;
  }

}