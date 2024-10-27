import 'package:aes/data/models/file_info.dart';
import 'package:aes/data/models/key_info.dart';

class KeyFileInfo {
  FileInfo fileInfo;
  KeyInfo keyInfo;

  KeyFileInfo({
    required this.fileInfo,
    required this.keyInfo,
  });

  factory KeyFileInfo.fromJson(Map<String, dynamic> json) {
    return KeyFileInfo(
      fileInfo: json['fileInfo'] ?? '',
      keyInfo: json['keyInfo'] ?? ''
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileInfo': fileInfo,
      'keyInfo': keyInfo
    };
  }
}
