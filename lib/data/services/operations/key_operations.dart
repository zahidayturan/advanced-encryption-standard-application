import 'package:aes/data/firebase/firebase_firestore_helper.dart';
import 'package:aes/data/models/key_info.dart';
import 'package:aes/data/services/key_service.dart';

class KeyOperations implements KeyService {

  @override
  Future<void> insertKeyInfo(KeyInfo keyInfo) async {
    await FirebaseFirestoreOperation().addKeyInfoToFirestore(keyInfo);
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

  @override
  Future<void> deleteKeyInfo(String keyId) async {
    await FirebaseFirestoreOperation().deleteKeyInfo(keyId);
  }

  @override
  Future<KeyInfo?> getKeyInfoWithUser(String uuid,String uid) async {
    var key = await FirebaseFirestoreOperation().getKeyInfoWithUserId(uuid,uid);
    return key;
  }

}