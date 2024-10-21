class FileInfo {
  String? id;
  String creationTime;
  String type;
  String name;
  String keyId;

  FileInfo({
    this.id,
    required this.creationTime,
    required this.type,
    required this.name,
    required this.keyId,
  });

  factory FileInfo.fromJson(Map<String, dynamic> json) {
    return FileInfo(
      id: json['id'] ?? '',
      creationTime: json['creationTime'] ?? '',
      type: json['type'] ?? '',
      name: json['name'] ?? '',
      keyId: json['keyId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creationTime': creationTime,
      'type': type,
      'name': name,
      'keyId': keyId
    };
  }
}
