import 'package:aes/data/firestore/firebase_firestore_helper.dart';
import 'package:aes/data/models/key_info.dart';
import 'package:aes/data/services/key_service.dart';

class KeyOperations implements KeyService {

  @override
  Future<void> insertKeyInfo(KeyInfo okuurUserInfo) async {
    await FirebaseFirestoreOperation().addKeyInfoToFirestore(okuurUserInfo);
  }

  @override
  Future<List<KeyInfo>?> getAllKeyInfo() async {
    var keys = await FirebaseFirestoreOperation().getAllKeyInfo();
    return keys;
  }

  @override
  Future<KeyInfo?> getKeyInfo(String id) async {
    var key = await FirebaseFirestoreOperation().getKeyInfo(id);
    return key;
  }

}