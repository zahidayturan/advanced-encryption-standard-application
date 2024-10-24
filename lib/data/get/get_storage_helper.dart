import 'package:get_storage/get_storage.dart';

class GetLocalStorage {
  // Singleton yapısı
  static final GetLocalStorage _instance = GetLocalStorage._internal();

  factory GetLocalStorage() {
    return _instance;
  }

  GetLocalStorage._internal();

  final GetStorage _storage = GetStorage();

  final String _bitLengthKey = "bitLength";
  final int _defaultBitLength = 256;

  Future<void> saveBitLength(int bitLength) async {
    await _storage.write(_bitLengthKey, bitLength);
  }

  int getBitLength() {
    return _storage.read<int>(_bitLengthKey) ?? _defaultBitLength;
  }

  Future<void> removeBitLength() async {
    await _storage.remove(_bitLengthKey);
  }



  Future<void> setValue(String key, dynamic value) async {
    await _storage.write(key, value);
  }

  T? getValue<T>(String key) {
    return _storage.read<T>(key);
  }

  Future<void> removeValue(String key) async {
    await _storage.remove(key);
  }

  Future<void> clearAll() async {
    await _storage.erase();
  }
}
