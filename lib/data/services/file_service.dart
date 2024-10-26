import 'dart:typed_data';

import 'package:aes/data/models/file_info.dart';

abstract class FileService {

  Future<List<FileInfo>?> getAllFileInfo();

  Future<void> insertFileInfo(FileInfo fileInfo,Uint8List encryptedBytes);

}
