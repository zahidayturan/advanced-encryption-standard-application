import 'package:aes/data/models/key_info.dart';

abstract class KeyService {

  Future<void> insertKeyInfo(KeyInfo keyInfo);

  Future<List<KeyInfo>?> getAllKeyInfo();

  Future<KeyInfo?> getKeyInfo(String id);

}
