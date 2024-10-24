import 'package:aes/data/models/key_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class FirebaseFirestoreOperation{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<void> addKeyInfoToFirestore(KeyInfo keyInfo) async {
    try {
      if (keyInfo.id == null || keyInfo.id!.isEmpty) {
        keyInfo.id = _firestore.collection('keys').doc().id;
      }
      Map<String, dynamic> keyData = keyInfo.toJson();
      await _firestore.collection('keys').doc(keyInfo.id).set(keyData);
    } catch (e) {
      print('Add Key Error: $e');
    }
  }

  Future<KeyInfo?> getKeyInfo(String uid) async {
    try {
      DocumentSnapshot keySnapshot = await _firestore.collection('keys').doc(uid).get();

      if (keySnapshot.exists) {
        Map<String, dynamic>? keyData = keySnapshot.data() as Map<String, dynamic>?;
        return keyData != null ? KeyInfo.fromJson(keyData) : null;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching key data: $e');
      return null;
    }
  }

  Future<List<KeyInfo>?> getAllKeyInfo() async {
    try {
      QuerySnapshot keySnapshot = await _firestore.collection('keys').get();

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
      print('Error fetching all key info: $e');
      return [];
    }
  }

  Future<void> deleteKeyInfo(String keyId) async {
    try {
      await _firestore.collection('keys').doc(keyId).delete();
    } catch (e) {
      print('Error deleting key: $e');
    }
  }



}