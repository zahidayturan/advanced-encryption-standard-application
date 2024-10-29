import 'package:aes/data/get/get_storage_helper.dart';
import 'package:aes/data/models/dto/key_file.dart';
import 'package:aes/data/models/file_info.dart';
import 'package:aes/data/models/key_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

final localStorage = GetLocalStorage();

class FirebaseFirestoreOperation{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addKeyInfoToFirestore(KeyInfo keyInfo) async {
    try {
      String? uuid = localStorage.getUUID();
      if (uuid == null || uuid.isEmpty) {
        throw Exception("UUID bulunamadı.");
      }
      if (keyInfo.id == null || keyInfo.id!.isEmpty) {
        keyInfo.id = _firestore.collection('users').doc(uuid).collection('keys').doc().id;
      }
      Map<String, dynamic> keyData = keyInfo.toJson();
      await _firestore.collection('users').doc(uuid).collection('keys').doc(keyInfo.id).set(keyData);
    } catch (e) {
      debugPrint('Add Key Error: $e');
    }
  }

  Future<KeyInfo?> getKeyInfo(String uid) async {
    try {
      String? uuid = localStorage.getUUID();
      if (uuid == null || uuid.isEmpty) {
        throw Exception("UUID bulunamadı.");
      }
      DocumentSnapshot keySnapshot = await _firestore.collection('users').doc(uuid).collection('keys').doc(uid).get();

      if (keySnapshot.exists) {
        Map<String, dynamic>? keyData = keySnapshot.data() as Map<String, dynamic>?;
        return keyData != null ? KeyInfo.fromJson(keyData) : null;
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching key data: $e');
      return null;
    }
  }

  Future<List<KeyInfo>?> getAllKeyInfo() async {
    try {
      String? uuid = localStorage.getUUID();
      if (uuid == null || uuid.isEmpty) {
        throw Exception("UUID bulunamadı.");
      }
      QuerySnapshot keySnapshot = await _firestore.collection('users').doc(uuid).collection('keys').get();

      if (keySnapshot.docs.isNotEmpty) {
        List<KeyInfo> keyList = keySnapshot.docs
            .map((doc) => KeyInfo.fromJson(doc.data() as Map<String, dynamic>))
            .toList();

        keyList.sort((a, b) {
          DateTime dateA = DateTime.parse(a.creationTime);
          DateTime dateB = DateTime.parse(b.creationTime);
          return dateB.compareTo(dateA);
        });

        return keyList;
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching all key info: $e');
      return [];
    }
  }

  Future<void> deleteKeyInfo(String keyId) async {
    try {
      String? uuid = localStorage.getUUID();
      if (uuid == null || uuid.isEmpty) {
        throw Exception("UUID bulunamadı.");
      }
      await _firestore.collection('users').doc(uuid).collection('keys').doc(keyId).delete();
    } catch (e) {
      debugPrint('Error deleting key: $e');
    }
  }

  Future<void> addFileInfoToFirestore(FileInfo fileInfo) async {
    try {
      String? uuid = localStorage.getUUID();
      if (uuid == null || uuid.isEmpty) {
        throw Exception("UUID bulunamadı.");
      }
      Map<String, dynamic> fileData = fileInfo.toJson();
      await _firestore.collection('users').doc(uuid).collection('files').doc(fileInfo.id).set(fileData);
    } catch (e) {
      debugPrint('Add Key Error: $e');
    }
  }

  Future<List<KeyFileInfo>?> getAllFileInfo() async {
    try {
      String? uuid = localStorage.getUUID();
      if (uuid == null || uuid.isEmpty) {
        throw Exception("UUID bulunamadı.");
      }
      List<KeyFileInfo> list = [];
      QuerySnapshot fileSnapshot = await _firestore.collection('users').doc(uuid).collection('files').get();

      if (fileSnapshot.docs.isNotEmpty) {
        List<FileInfo> fileList = fileSnapshot.docs
            .map((doc) => FileInfo.fromJson(doc.data() as Map<String, dynamic>))
            .toList();

        fileList.sort((a, b) {
          DateTime dateA = DateTime.parse(a.creationTime);
          DateTime dateB = DateTime.parse(b.creationTime);
          return dateB.compareTo(dateA);
        });

        for (FileInfo element in fileList) {
          KeyInfo? key = await getKeyInfo(element.keyId);
          if (key != null) {
            list.add(KeyFileInfo(fileInfo: element, keyInfo: key));
          }
          if(element.keyId == "tempKey"){
            list.add(KeyFileInfo(fileInfo: element, keyInfo: KeyInfo(
                id: "tempKey",
                name: "?",
                creationTime: "?",
                bitLength: "?",
                generateType: "?",
                key: "?")));
          }
        }
        return list;
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching all file info: $e');
      return [];
    }
  }

  Future<void> deleteFileInfo(String fileId) async {
    try {
      String? uuid = localStorage.getUUID();
      if (uuid == null || uuid.isEmpty) {
        throw Exception("UUID bulunamadı.");
      }
      await _firestore.collection('users').doc(uuid).collection('files').doc(fileId).delete();
    } catch (e) {
      debugPrint('Error deleting file: $e');
    }
  }

  Future<List<int>> getFileCountForInfo() async {
    String? uuid = localStorage.getUUID();
    if (uuid == null || uuid.isEmpty) {
      throw Exception("UUID bulunamadı.");
    }
    QuerySnapshot userFiles = await _firestore.collection('users').doc(uuid).collection('files').get();
    int fileCount = userFiles.docs.length;
    return [fileCount, 0];
  }
}