import 'package:aes/data/models/file_info.dart';

abstract class FileService {

  Future<List<FileInfo>?> getAllFileInfo();

}
