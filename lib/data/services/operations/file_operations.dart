import 'dart:convert';
import 'dart:typed_data';
import 'package:aes/data/firebase/firebase_firestore_helper.dart';
import 'package:aes/data/firebase/firebase_storage_helper.dart';
import 'package:aes/data/models/dto/key_file.dart';
import 'package:aes/data/models/file_info.dart';
import 'package:aes/data/services/file_service.dart';
import 'package:encrypt/encrypt.dart';

class FileOperations implements FileService {

  @override
  Future<List<KeyFileInfo>?> getAllFileInfo(String fileType) async {
    var files = await FirebaseFirestoreOperation().getAllFileInfo(fileType);
    return files;
  }

  @override
  Future<void> insertFileInfo(FileInfo fileInfo,Uint8List encryptedBytes) async {
    await FirebaseStorageOperation().uploadFileToFirebase(fileInfo, encryptedBytes);
  }

  @override
  Future<void>deleteFileInfo(FileInfo fileInfo) async {
    await FirebaseStorageOperation().deleteFileFromFirebase(fileInfo);
  }

  @override
  Future<List<int>?> getDecryptedFile(FileInfo fileInfo, String keyData) async {
    Uint8List? encryptedBytes = await FirebaseStorageOperation().getFileFromFirebase(fileInfo);

    if (encryptedBytes == null) {
      print("Şifreli dosya alınamadı.");
      return [];
    }

    final key = Key.fromBase64(keyData);
    final iv = IV.fromBase64(fileInfo.iv);

    final encrypter = Encrypter(AES(key));
    final encryptedData = Encrypted(encryptedBytes);
    final decryptedBytes = encrypter.decryptBytes(encryptedData, iv: iv);

    return decryptedBytes;
  }

  @override
  Future<List<int>?> getEncryptedFile(FileInfo fileInfo) async {
    Uint8List? encryptedBytes = await FirebaseStorageOperation().getFileFromFirebase(fileInfo);
    return encryptedBytes;
  }

  @override
  Future<List<int>>getFileCountForInfo() async {
    List<int> dataList = await FirebaseFirestoreOperation().getFileCountForInfo();
    return dataList;
  }

  @override
  Future<FileInfo?> getFileInfoWithUser(String uuid,String uid) async {
    var file = await FirebaseFirestoreOperation().getFileInfoWithUserId(uuid,uid);
    return file;
  }

  @override
  Future<void> insertReceivingFile(FileInfo fileInfo) async {
    await FirebaseFirestoreOperation().uploadReceivingFileToFirebase(fileInfo);
  }

  @override
  Future<void>deleteReceivingFile(String fileId) async {
    await FirebaseFirestoreOperation().deleteReceivingFileFromFirebase(fileId);
  }

  @override
  Future<void> deleteAllUserData() async {
    await FirebaseFirestoreOperation().deleteAllData();
  }

}