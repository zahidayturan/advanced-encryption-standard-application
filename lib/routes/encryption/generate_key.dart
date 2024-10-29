import 'package:aes/core/constants/colors.dart';
import 'package:aes/data/get/get_storage_helper.dart';
import 'package:aes/data/models/key_info.dart';
import 'package:aes/data/services/operations/key_operations.dart';
import 'package:aes/routes/encryption/components/e_page_app_bar.dart';
import 'package:aes/ui/components/loading.dart';
import 'package:aes/ui/components/regular_text.dart';
import 'package:aes/ui/components/text_field.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';

import 'package:qr_flutter/qr_flutter.dart';

class GenerateKey extends StatefulWidget {
  final String codeOrPath;
  final String type;
  const GenerateKey({super.key, required this.codeOrPath, required this.type});

  @override
  State<GenerateKey> createState() => _GenerateKeyState();
}

class _GenerateKeyState extends State<GenerateKey> {
  AppColors colors = AppColors();
  int bitLength = 256;
  String generatedKey = "";
  KeyOperations keyOperations = KeyOperations();
  final localStorage = GetLocalStorage();

  final _nameController = TextEditingController(text: "Anahtarım");
  bool checkedValue = true;

  @override
  void initState() {
    super.initState();
    _loadBitLength();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadBitLength() async {
    int savedBitLength = localStorage.getBitLength();
    setState(() {
      bitLength = savedBitLength;
    });
  }

  String generatePaddedKey(String code, int bitLength) {
    int targetLength = bitLength ~/ 8;

    List<int> codeBytes = utf8.encode(code);
    debugPrint(codeBytes.length.toString());

    if (codeBytes.length > targetLength) {
      codeBytes = codeBytes.sublist(0, targetLength);
    }

    if (codeBytes.length < targetLength) {
      int paddingLength = targetLength - codeBytes.length;
      codeBytes = List.from(codeBytes)..addAll(List.generate(paddingLength, (_) => 0));
    }

    debugPrint(codeBytes.length.toString());
    debugPrint(codeBytes.toString());
    debugPrint(utf8.decode(codeBytes));
    debugPrint(base64.encode(codeBytes));

    final key = encrypt.Key.fromBase64(base64.encode(codeBytes));
    debugPrint('Key Length: ${key.length} bytes');

    final keyBytes = key.bytes;
    String keyHex = keyBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    debugPrint('Key (Hex): $keyHex');

    String keyBase64 = base64.encode(keyBytes);
    debugPrint('Key (Base64): $keyBase64');
    return keyBase64;
  }

  Future<List<int>> readAudioFile(String path) async {
    File audioFile = File(path);
    List<int> audioBytes = await audioFile.readAsBytes();
    debugPrint(audioBytes.toString());
    return audioBytes;
  }

  Future<String> generateKeyFromAudio(String path, int bitLength) async {
    List<int> audioBytes = await readAudioFile(path);
    int targetLength = bitLength ~/ 8;
    if (audioBytes.length > targetLength) {
      audioBytes = audioBytes.sublist(0, targetLength);
    }
    if (audioBytes.length < targetLength) {
      int paddingLength = targetLength - audioBytes.length;
      audioBytes = List.from(audioBytes)..addAll(List.generate(paddingLength, (_) => 0));
    }
    final key = encrypt.Key.fromBase64(base64.encode(audioBytes));
    String keyBase64 = base64.encode(key.bytes);
    return keyBase64;
  }

  Future<void> _handleAdKey(BuildContext context) async {
    LoadingDialog.showLoading(context, message: "Anahtar Üretiliyor");

    try {
      if (widget.type == "qr") {
        generatedKey = generatePaddedKey(widget.codeOrPath, bitLength);
      } else if (widget.type == "voice") {
        generatedKey = await generateKeyFromAudio(widget.codeOrPath, bitLength);
      } else {
        throw Exception("Geçersiz anahtar üretme tipi: ${widget.type}");
      }

      KeyInfo newKey = KeyInfo(
        creationTime: DateTime.now().toString(),
        name: _nameController.text,
        bitLength: bitLength.toString(),
        generateType: widget.type,
        key: generatedKey,
      );
      debugPrint(newKey.toJson().toString());
      if(checkedValue){
        await keyOperations.insertKeyInfo(newKey);
      }
      Navigator.pop(context,'updated');
      LoadingDialog.hideLoading(context).then((value) => showKeyDetails(context,newKey));
    } catch (e) {
      debugPrint("Bir hata oluştu: $e");
      LoadingDialog.hideLoading(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: RegularText(texts: "Anahtar üretimi sırasında hata oluştu",color: colors.grey,),backgroundColor: colors.red,behavior: SnackBarBehavior.floating,),
      );
    }
  }

  void showKeyDetails(BuildContext context, KeyInfo keyInfo) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      barrierColor: Theme.of(context).colorScheme.secondary.withOpacity(0.075),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.green,
                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                  ),
                ),
                const SizedBox(height: 16),
                RegularText(
                  texts: "Anahtar üretildi",
                  size: 16,
                  weight: FontWeight.bold,
                  color: colors.green,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: RegularText(
                        texts: keyInfo.key,
                        maxLines: 3,
                        size: 13,
                        align: TextAlign.center,
                        color: colors.orange,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.copy, color: Theme.of(context).colorScheme.secondary),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: keyInfo.key));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: RegularText(texts: 'Anahtar panoya kopyalandı', color: colors.grey),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                          backgroundColor: colors.green,
                          margin: EdgeInsets.only(
                              bottom: MediaQuery.of(context).size.height - 100),
                        ));
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                RegularText(
                  texts: keyInfo.creationTime,
                  maxLines: 3,
                  size: 11,
                  align: TextAlign.center,
                ),
                const SizedBox(height: 8),
                QrImageView(
                  data: keyInfo.key,
                  version: QrVersions.auto,
                  size: 150.0,
                  backgroundColor: colors.grey,
                ),
                const SizedBox(height: 8),
                const RegularText(
                  texts: "Üretilen anahtarı paylaşmak isterseniz, diğer cihazda QR ile anahtar al menüsünde bu kodu okutunuz.",
                  maxLines: 5,
                  size: 13,
                  align: TextAlign.center,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        resizeToAvoidBottomInset: false,
        bottomNavigationBar: null,
        body: Padding(
          padding: const EdgeInsets.only(right: 12, left: 12, top: 6),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const EPageAppBar(
                  texts: "Anahtar Üretimi",
                  dataChanged: false,
                ),
                const SizedBox(height: 12),
                const FullTextField(
                    fieldName: "Şifreleme Verisi",
                    hintText: "Alındı",
                    readOnly: true,
                    border: false,
                    myIcon: Icons.info_outline_rounded),
                const SizedBox(height: 24),
                FullTextField(
                    fieldName: "Anahtar Güvenliği",
                    hintText: "AES-$bitLength",
                    readOnly: true,
                    border: false,
                    myIcon: Icons.security_rounded),
                const SizedBox(height: 24),
                FullTextField(
                    fieldName: "Anahtar Üretim Türü",
                    hintText: widget.type == "qr" ? "QR Kod ile" : "Ses ile",
                    readOnly: true,
                    border: false,
                    myIcon: Icons.merge_type_rounded),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: FullTextField(
                          fieldName: "Anahtar Kayıt",
                          hintText: checkedValue ? "Kaydedilsin" : "Kaydedilmesin",
                          readOnly: true,
                          border: false,
                          myIcon: Icons.save),
                    ),
                    SizedBox(
                      width: 32,
                      child: Checkbox(
                        value: checkedValue,
                        activeColor: Theme.of(context).colorScheme.tertiary,
                        checkColor: Theme.of(context).primaryColor,
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.tertiary
                        ),
                        onChanged: (newValue) {
                          setState(() {
                            checkedValue = newValue!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                FullTextField(
                    myController: _nameController,
                    fieldName: "Anahtar İsmi",
                    hintText: "Anahtarım",
                    readOnly: false,
                    border: true,
                    myIcon: Icons.key_rounded),
                //RegularText(texts: widget.codeOrPath),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _handleAdKey(context),
                        child: RegularText(
                          texts: "Anahtarı Üret",
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
    );
  }
}
