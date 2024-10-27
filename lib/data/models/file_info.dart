class FileInfo {
  String? id;
  String creationTime;
  String type;
  String name;
  String originalName;
  String keyId;

  FileInfo({
    this.id,
    required this.creationTime,
    required this.type,
    required this.name,
    required this.originalName,
    required this.keyId,
  });

  factory FileInfo.fromJson(Map<String, dynamic> json) {
    return FileInfo(
      id: json['id'] ?? '',
      creationTime: json['creationTime'] ?? '',
      type: json['type'] ?? '',
      name: json['name'] ?? '',
      originalName: json['originalName'] ?? '',
      keyId: json['keyId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creationTime': creationTime,
      'type': type,
      'name': name,
      'originalName': originalName,
      'keyId': keyId
    };
  }
}
