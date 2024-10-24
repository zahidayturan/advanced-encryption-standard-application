import 'package:aes/core/constants/colors.dart';
import 'package:aes/data/models/key_info.dart';
import 'package:aes/data/services/operations/key_operations.dart';
import 'package:aes/routes/encryption/components/e_page_app_bar.dart';
import 'package:aes/ui/components/regular_text.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

class GenerateKey extends StatefulWidget {
  final String codeOrPath;
  final String type;
  const GenerateKey({super.key, required this.codeOrPath, required this.type});

  @override
  State<GenerateKey> createState() => _GenerateKeyState();
}

class _GenerateKeyState extends State<GenerateKey> {
  AppColors colors = AppColors();
  final int bitLength = 256;
  String generatedKey = "";

  KeyOperations keyOperations = KeyOperations();

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
                ),
                RegularText(texts: bitLength.toString()),
                RegularText(texts: widget.codeOrPath),
                RegularText(texts: widget.type),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                            if(widget.type == "qr"){
                              setState(() {
                                generatedKey = generatePaddedKey(widget.codeOrPath, bitLength);
                              });
                            } else if(widget.type == "voice"){
                              String key = await generateKeyFromAudio(widget.codeOrPath, bitLength);
                              setState(() {
                                generatedKey = key;
                              });
                            }
                          KeyInfo newKey = KeyInfo(
                            creationTime: DateTime.now().toString(),
                            bitLength: bitLength.toString(),
                            generateType: widget.type,
                            key: generatedKey,
                          );
                           await keyOperations.insertKeyInfo(newKey);
                          debugPrint(newKey.toJson().toString());
                        },

                        child: RegularText(
                          texts: "Anahtarı Üret",
                          size: 15,
                          color: colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(generatedKey,style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
