import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:aes/core/constants/colors.dart';
import 'package:aes/data/models/file_info.dart';
import 'package:aes/data/models/key_info.dart';
import 'package:aes/data/services/operations/file_operations.dart';
import 'package:aes/data/services/operations/key_operations.dart';
import 'package:aes/routes/encryption/components/e_page_app_bar.dart';
import 'package:aes/ui/components/base_container.dart';
import 'package:aes/ui/components/loading.dart';
import 'package:aes/ui/components/regular_text.dart';
import 'package:aes/ui/components/text_field.dart';
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
  List<KeyInfo> keyList = [];
  KeyInfo? activeKey;

  final _fileNameController = TextEditingController(text: "Dosyam");
  final _tempKeyController = TextEditingController();

  String? fileName;
  int? fileSize;

  @override
  void initState() {
    super.initState();
    getFileInfo();
    getKeyList();
  }

  Future<void> getKeyList() async {
    List<KeyInfo>? data = await keyOperations.getAllKeyInfo();
    setState(() {
      if (data != null && data.isNotEmpty) {
        keyList = data;
        activeKey = keyList.first;
      } else {
        showChooseKeyMenu();
      }
    });
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
    LoadingDialog.showLoading(context, message: "Dosya Şifreleniyor");

    try {
      if (widget.filePath != null && activeKey != null) {
        File file = File(widget.filePath!);
        Uint8List fileBytes = file.readAsBytesSync();
        debugPrint(fileBytes.length.toString());
        debugPrint(fileBytes.toString());


        final key = encrypt.Key.fromBase64(activeKey!.key);
        final iv = encrypt.IV.fromLength(16);
        final encrypter = encrypt.Encrypter(encrypt.AES(key));
        final encrypted = encrypter.encryptBytes(fileBytes, iv: iv);
        debugPrint(encrypted.bytes.length.toString());
        debugPrint(encrypted.bytes.toString());


        final fileName = path.basename(widget.filePath!);
        final fileExtension = path.extension(widget.filePath!);

        FileInfo newFile = FileInfo(
          creationTime: DateTime.now().toString(),
          type: fileExtension,
          name: _fileNameController.text.toString(),
          originalName: fileName,
          size: fileSize!,
          keyId: activeKey!.id!,
          iv: iv.base64,
        );

        await fileOperations.insertFileInfo(newFile, encrypted.bytes);
        Navigator.of(context).pop();
        LoadingDialog.hideLoading(context);
        showSuccessAlert();
      }
    } catch (e) {
      debugPrint("Bir hata oluştu: $e");
      LoadingDialog.hideLoading(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: RegularText(texts: "Dosya şifrelenirken hata oluştu", color: colors.grey),
          backgroundColor: colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
                  const EPageAppBar(texts: "Dosya Şifrele",dataChanged: false),
                  const SizedBox(height: 12),
                  if (activeKey != null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: FullTextField(
                              fieldName: "Şifreleme Anahtarı",
                              hintText: activeKey!.name != ""
                                  ? activeKey!.name
                                  : "İsimsiz Anahtar",
                              readOnly: true,
                              border: false,
                              myIcon: Icons.key_rounded),
                        ),
                        InkWell(
                          onTap: () {
                            showChooseKeyMenu();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: RegularText(
                              texts: "Değiştir",
                              size: 14,
                              color: colors.orange,
                            ),
                          ),
                        ),
                      ],
                    )
                  ] else
                    CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  if (fileName != null && fileSize != null) ...[
                    const SizedBox(height: 24),
                    FullTextField(
                        fieldName: "Dosya Bilgisi",
                        hintText: fileName.toString(),
                        readOnly: true,
                        border: false,
                        myIcon: Icons.file_present),
                    const SizedBox(height: 24),
                    FullTextField(
                        fieldName: "Dosya Boyutu",
                        hintText: "${(fileSize! / 1024).toStringAsFixed(2)} KB",
                        readOnly: true,
                        border: false,
                        myIcon: Icons.cloud_outlined),
                  ] else
                    CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  const SizedBox(height: 24),
                  FullTextField(
                      myController: _fileNameController,
                      fieldName: "Dosya İsmi",
                      hintText: "Dosyam",
                      readOnly: false,
                      border: true,
                      myIcon: Icons.drive_file_rename_outline_outlined),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _handleEncryptFile(context),
                          child: RegularText(
                            texts: "Dosyayı Şifrele ve Yükle",
                            size: 16,
                            color: colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showChooseKeyMenu() {
    showDialog(
        context: context,
        barrierDismissible: activeKey == null ?  false : true,
        barrierColor: Theme.of(context).colorScheme.secondary.withOpacity(0.075),
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            contentPadding: const EdgeInsets.all(8),
            insetPadding: const EdgeInsets.all(16),
            content: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: RegularText(
                        texts: "Kayıtlı Anahtarlar",
                        family: "FontBold",
                        size: 16,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if(activeKey == null){
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.close_rounded),
                      alignment: Alignment.centerRight,
                    )
                  ],
                ),
                BaseContainer(
                    child:
                    Row(
                      children: [
                        Expanded(
                          child: FullTextField(
                            myController: _tempKeyController,
                            fieldName: "Geçici Anahtar Ekle",
                            hintText: "Anahtarı giriniz",
                            myIcon: Icons.add_box_outlined,
                            border: false,
                            readOnly: false),
                        ),
                        const SizedBox(width: 8,),
                        ElevatedButton(
                          onPressed: () async {
                            int decodedInputLength = base64Decode(_tempKeyController.text).length;
                            if(decodedInputLength == 16 ||
                                decodedInputLength == 24 ||
                                decodedInputLength == 32){
                              KeyInfo tempKey = KeyInfo(
                                id: "tempKey",
                                name: "Geçici Anahtar",
                                creationTime: DateTime.now().toString(),
                                bitLength: (decodedInputLength*8).toString(),
                                generateType: "userInput",
                                key: _tempKeyController.text.toString(),
                              );
                              setState(() {
                                activeKey = tempKey;
                              });
                              Navigator.pop(context);
                            }else{
                              var snackBar = SnackBar(content: Text('Geçersiz Anahtar Uzunluğu',style: TextStyle(color: colors.grey),),backgroundColor: colors.red,);
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(colors.black),
                            padding: const MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 4)),
                          ),
                          child: RegularText(
                            texts: "Ekle", color: colors.grey,
                          ),
                        )

                      ],
                    )),
                const SizedBox(height: 8,),
                SizedBox(
                  height: keyList.isNotEmpty ? 240 : 36,
                  width: MediaQuery.of(context).size.width,
                  child: keyList.isNotEmpty ? ListView.builder(
                    itemCount: keyList.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      var item = keyList[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: BaseContainer(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RegularText(
                                      texts: item.name != ""
                                          ? item.name
                                          : "İsimsiz Anahtar",
                                      size: 13,
                                    ),
                                    RegularText(
                                      texts: item.creationTime,
                                      size: 12,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    activeKey = item;
                                    Navigator.pop(context);
                                  });
                                },
                                style: ButtonStyle(
                                  padding: const MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 4)),
                                    backgroundColor: activeKey!.id == item.id
                                        ? MaterialStatePropertyAll(colors.orange)
                                        : MaterialStatePropertyAll(Theme.of(context)
                                            .colorScheme
                                            .tertiaryContainer)),
                                child: RegularText(
                                  texts:
                                      activeKey!.id == item.id ? "Seçili" : "Seç",
                                  color: colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ):
                  RegularText(texts: "Kayıtlı anahtar bulunumadı.\nŞifreleme için anahtarı giriniz.",maxLines: 5,align: TextAlign.center,),
                ),


              ],
            ),
          );
        });
  }

  void showSuccessAlert(){
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            contentPadding: const EdgeInsets.all(16),
            insetPadding: const EdgeInsets.all(16),
            content: Column(
              children: [
                RegularText(texts: "Şifreleme Başarılı",color: Theme.of(context).colorScheme.tertiary,weight: FontWeight.bold,),
                const SizedBox(height: 16,),
                Icon(Icons.check_circle_outline_rounded,size: 64,color: Theme.of(context).colorScheme.tertiary),
                const SizedBox(height: 16,),
                InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: BaseContainer(
                              color: Theme.of(context).colorScheme.tertiaryContainer,
                              child: Center(child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: RegularText(texts: "Tamam",color: colors.grey,size: 14),
                              ))),
                        ),
                      ],
                    ))
              ],
            ),
          );
        });
  }
}
