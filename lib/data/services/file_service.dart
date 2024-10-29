import 'dart:typed_data';

import 'package:aes/data/models/dto/key_file.dart';
import 'package:aes/data/models/file_info.dart';

abstract class FileService {

  Future<List<KeyFileInfo>?> getAllFileInfo();

  Future<void> insertFileInfo(FileInfo fileInfo,Uint8List encryptedBytes);

  Future<void>deleteFileInfo(FileInfo fileInfo);

  Future<List<int>?>getDecryptedFile(FileInfo fileInfo,String key);

  Future<List<int>?>getEncryptedFile(FileInfo fileInfo);

  Future<List<int>>getFileCountForInfo();

}
