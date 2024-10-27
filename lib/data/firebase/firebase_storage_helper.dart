import 'dart:typed_data';

import 'package:aes/data/firebase/firebase_firestore_helper.dart';
import 'package:aes/data/models/file_info.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';


class FirebaseStorageOperation{
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  final Uuid uuid = const Uuid();

  Future<void> uploadFileToFirebase(FileInfo fileInfo, Uint8List encryptedBytes) async {
    try {

      final uniqueId = uuid.v4();
      final storageRef =_firebaseStorage.ref().child("encrypted_files/$uniqueId/${fileInfo.originalName}");
      await storageRef.putData(encryptedBytes);
      debugPrint("Dosya storage e başarıyla yüklendi.");
      fileInfo.id = uniqueId;
      await FirebaseFirestoreOperation().addFileInfoToFirestore(fileInfo);
      debugPrint("Dosya firestore a başarıyla yüklendi.");
    } catch (e) {
      debugPrint("Dosya yükleme hatası: $e");
    }
  }

  Future<void> deleteFileFromFirebase(FileInfo fileInfo) async {
    try {
      final storageRef =_firebaseStorage.ref().child("encrypted_files/${fileInfo.id!}/${fileInfo.originalName}");
      await storageRef.delete();
      debugPrint("Dosya storage den silindi");
      await FirebaseFirestoreOperation().deleteFileInfo(fileInfo.id!);
      debugPrint("Dosya firestore dan silindi");
    } catch (e) {
      debugPrint("Dosya silme hatası: $e");
    }
  }

}