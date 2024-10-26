class KeyInfo {
  String? id;
  String name;
  String creationTime;
  String bitLength;
  String generateType;
  String key;

  KeyInfo({
    this.id,
    required this.name,
    required this.creationTime,
    required this.bitLength,
    required this.generateType,
    required this.key,
  });

  factory KeyInfo.fromJson(Map<String, dynamic> json) {
    return KeyInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      creationTime: json['creationTime'] ?? '',
      bitLength: json['bitLength'] ?? '',
      generateType: json['generateType'] ?? '',
      key: json['key'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'creationTime': creationTime,
      'bitLength': bitLength,
      'generateType': generateType,
      'key': key
    };
  }
}
