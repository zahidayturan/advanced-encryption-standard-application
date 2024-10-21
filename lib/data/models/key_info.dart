class KeyInfo {
  String? id;
  String creationTime;
  String bitLength;
  String generateType;
  String key;

  KeyInfo({
    this.id,
    required this.creationTime,
    required this.bitLength,
    required this.generateType,
    required this.key,
  });

  factory KeyInfo.fromJson(Map<String, dynamic> json) {
    return KeyInfo(
      id: json['id'] ?? '',
      creationTime: json['creationTime'] ?? '',
      bitLength: json['bitLength'] ?? '',
      generateType: json['generateType'] ?? '',
      key: json['key'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creationTime': creationTime,
      'bitLength': bitLength,
      'generateType': generateType,
      'key': key
    };
  }
}
