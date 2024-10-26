import 'dart:convert';
import 'dart:io';
import 'package:aes/core/constants/colors.dart';
import 'package:aes/data/models/file_info.dart';
import 'package:aes/data/services/operations/file_operations.dart';
import 'package:aes/data/services/operations/key_operations.dart';
import 'package:aes/routes/encryption/components/e_page_app_bar.dart';
import 'package:aes/ui/components/regular_text.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class FileEncryption extends StatefulWidget {
  final String? filePath;
  const FileEncryption({super.key, required this.filePath});

  @override
  State<FileEncryption> createState() => _FileEncryptionState();
}

class _FileEncryptionState extends State<FileEncryption> {
  AppColors colors = AppColors();
  KeyOperations keyOperations = KeyOperations();
  FileOperations fileOperations = FileOperations();
  String originalFileBytes = "";
  String encryptedFileBytes = "";

  String? fileName;
  int? fileSize;

  @override
  void initState() {
    super.initState();
    getFileInfo();
  }

  Future<void> getFileInfo() async {
    if (widget.filePath != null) {
      File file = File(widget.filePath!);
      setState(() {
        fileName = file.uri.pathSegments.last;
        fileSize = file.lengthSync();
      });
    }
  }

  Future<void> _handleEncryptFile(BuildContext context) async {
    if (widget.filePath != null) {
      File file = File(widget.filePath!);
      final fileBytes = file.readAsBytesSync();
      setState(() {
        originalFileBytes = base64.encode(fileBytes);
      });

      final key = encrypt.Key.fromUtf8('my 32 length key................');
      final iv = encrypt.IV.fromLength(16);

      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      final base64String = base64.encode(fileBytes);

      final encrypted = encrypter.encrypt(base64String, iv: iv);
      final encryptedBytes = base64.decode(encrypted.base64);

      setState(() {
        encryptedFileBytes = encrypted.base64;
      });

      final fileName = path.basename(widget.filePath!);
      final fileExtension = path.extension(widget.filePath!);

      FileInfo newFile = FileInfo(
          creationTime: DateTime.now().toString(),
          type: fileExtension,
          name: fileName,
          keyId: "1");

      await fileOperations.insertFileInfo(newFile,encryptedBytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: const EdgeInsets.only(right: 12, left: 12, top: 6),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Center(
              child: Column(
                children: [
                  const EPageAppBar(texts: "Dosya Şifrele"),
                  const SizedBox(height: 20),
                  if (fileName != null && fileSize != null) ...[
                    Text(
                      "Dosya Adı: $fileName",
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Dosya Boyutu: ${(fileSize! / 1024).toStringAsFixed(2)} KB",
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ] else
                    const CircularProgressIndicator(),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _handleEncryptFile(context),
                          child: RegularText(
                            texts: "Dosyayı Şifrele ve Yükle",
                            size: 15,
                            color: colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(originalFileBytes.length.toString(), style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 7)),
                  Text(originalFileBytes, style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 7)),
                  Text(encryptedFileBytes.length.toString(), style: TextStyle(color: colors.green, fontSize: 7)),
                  Text(encryptedFileBytes, style: TextStyle(color: colors.green, fontSize: 7)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
