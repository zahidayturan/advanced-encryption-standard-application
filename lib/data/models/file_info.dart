class FileInfo {
  String? id;
  String creationTime;
  String type;
  String name;
  String originalName;
  int size;
  String keyId;
  String iv;

  FileInfo({
    this.id,
    required this.creationTime,
    required this.type,
    required this.name,
    required this.originalName,
    required this.size,
    required this.keyId,
    required this.iv
  });

  factory FileInfo.fromJson(Map<String, dynamic> json) {
    return FileInfo(
      id: json['id'] ?? '',
      creationTime: json['creationTime'] ?? '',
      type: json['type'] ?? '',
      name: json['name'] ?? '',
      originalName: json['originalName'] ?? '',
      size: json['size'] ?? '',
      keyId: json['keyId'] ?? '',
      iv: json['iv'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creationTime': creationTime,
      'type': type,
      'name': name,
      'originalName': originalName,
      'size': size,
      'keyId': keyId,
      'iv': iv
    };
  }
}
