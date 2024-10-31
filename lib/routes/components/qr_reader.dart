import 'dart:io';
import 'package:aes/core/constants/colors.dart';
import 'package:aes/data/models/file_info.dart';
import 'package:aes/data/models/key_info.dart';
import 'package:aes/data/services/operations/file_operations.dart';
import 'package:aes/data/services/operations/key_operations.dart';
import 'package:aes/routes/encryption/generate_key.dart';
import 'package:aes/ui/components/loading.dart';
import 'package:aes/ui/components/regular_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRCodeReadPage extends StatefulWidget {
  final String type;
  const QRCodeReadPage({super.key,required this.type});

  @override
  State<QRCodeReadPage> createState() => _QRCodeReadPageState();
}

class _QRCodeReadPageState extends State<QRCodeReadPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  AppColors colors = AppColors();
  KeyOperations keyOperations = KeyOperations();
  FileOperations fileOperations = FileOperations();

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          iconTheme: IconThemeData(color: Theme.of(context).colorScheme.secondary),
          title: RegularText(texts: widget.type == "barcode" ? "Barkod Okuyucu" : "QR Kod Okuyucu",size: 17)),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 6,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: result != null ? colors.green : Theme.of(context).scaffoldBackgroundColor ,
              child: Center(
                child: (result != null)
                    ? RegularText(texts:'Kod Okundu, Bekleyiniz',color: colors.grey,)
                    : RegularText(texts: widget.type == "barcode" ? "Barkodu Okutunuz" : 'QR Kodu Okutunuz'),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((scanData) async {
      if (!mounted) return;

      setState(() {
        result = scanData;
      });

      if (scanData.code != null) {
        await Future.delayed(const Duration(milliseconds: 1500));

        if (!mounted) return;


        if(widget.type == "qr" || widget.type == "barcode"){
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GenerateKey(codeOrPath: scanData.code!,type:widget.type)),
          );
        }else if(widget.type == "returnKey"){
          try {
            List<String> parts = scanData.code!.split('/');
            if (parts.length >= 2) {
              String id = parts[0];
              String kid = parts[1];
              KeyInfo? receivingKey = await keyOperations.getKeyInfoWithUser(id, kid);
              if (receivingKey != null) {
                Navigator.of(context).pop();
                showQRGeneratorForKey(receivingKey);
              } else {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: RegularText(texts: "Bir anahtar bulunamadı", color: colors.grey),
                    backgroundColor: colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            } else {
              Navigator.pop(context, null);
            }
          } catch (e) {
            LoadingDialog.hideLoading(context);
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: RegularText(texts: "Bir hata oluştu: $e", color: colors.grey),
                backgroundColor: colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }else if (widget.type == "returnFile") {
          try {
            List<String> parts = scanData.code!.split('/');
            if (parts.length >= 2) {
              String id = parts[0];
              String fid = parts[1];
              FileInfo? receivingFile = await fileOperations.getFileInfoWithUser(id, fid);
              if (receivingFile != null) {
                Navigator.of(context).pop();
                showQRGeneratorForFile(receivingFile);
              } else {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: RegularText(texts: "Bir dosya bulunamadı", color: colors.grey),
                    backgroundColor: colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            } else {
              Navigator.pop(context, null);
            }
          } catch (e) {
            LoadingDialog.hideLoading(context);
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: RegularText(texts: "Bir hata oluştu: $e", color: colors.grey),
                backgroundColor: colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else{
          Navigator.pop(context);
        }
    }});
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void showQRGeneratorForFile(FileInfo fileInfo) {
    showModalBottomSheet(
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
              children: [
                Container(width: 60,height: 4,decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: const BorderRadius.all(Radius.circular(50))
                ),),
                const SizedBox(height: 24),
                RegularText(
                  texts: "Dosya alındı",
                  color: Theme.of(context).colorScheme.secondary,
                  family: "FontBold",
                  size: 16,
                ),
                const SizedBox(height: 4),
                RegularText(
                  texts: fileInfo.name != "" ? fileInfo.name : "İsimsiz Dosya",
                  maxLines: 3,
                  size: 12,
                  align: TextAlign.center,
                ),
                const SizedBox(height: 4),
                RegularText(
                  texts: fileInfo.type,
                  size: 9,
                  align: TextAlign.center,
                ),
                const SizedBox(height: 4),
                RegularText(
                  texts: "${(fileInfo.size / 1024).toStringAsFixed(2)} KB",
                  size: 9,
                  align: TextAlign.center,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                    onPressed: () async {
                      LoadingDialog.showLoading(context,message: "Dosya kaydediliyor");
                      await fileOperations.insertReceivingFile(fileInfo).then((value) {
                        LoadingDialog.hideLoading(context);
                        Navigator.of(context).pop();
                        setState(() {
                        });
                      });
                    }, child: RegularText(texts: "Dosyayı kaydet ve çık",color: colors.grey,)),
              ],
            ),
          ),
        );
      },
    );
  }

  void showQRGeneratorForKey(KeyInfo keyInfo) {
    showModalBottomSheet(
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
              children: [
                Container(width: 60,height: 4,decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: const BorderRadius.all(Radius.circular(50))
                ),),
                const SizedBox(height: 24),
                RegularText(
                  texts: "Anahtar alındı",
                  color: Theme.of(context).colorScheme.secondary,
                  family: "FontBold",
                  size: 16,
                ),
                const SizedBox(height: 4),
                RegularText(
                  texts: keyInfo.name != "" ? keyInfo.name : "İsimsiz Anahtar",
                  maxLines: 3,
                  size: 12,
                  align: TextAlign.center,
                ),
                const SizedBox(height: 4),
                RegularText(
                  texts: keyInfo.key,
                  size: 9,
                  align: TextAlign.center,
                ),
                const SizedBox(height: 4),
                RegularText(
                  texts: "AES-${keyInfo.bitLength}",
                  size: 9,
                  align: TextAlign.center,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                    onPressed: () async {
                      LoadingDialog.showLoading(context,message: "Anahtar kaydediliyor");
                      await keyOperations.insertKeyInfo(keyInfo).then((value) {
                        LoadingDialog.hideLoading(context);
                        Navigator.of(context).pop();
                        setState(() {

                        });
                      });

                    }, child: RegularText(texts: "Anahtarı kaydet ve çık",color: colors.grey,)),
                const SizedBox(height: 8),
                ElevatedButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: keyInfo.key));
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: RegularText(texts: 'Anahtar panoya kopyalandı', color: colors.grey),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: colors.green,
                      ));

                    }, child: RegularText(texts: "Anahtarı kopyala ve çık",color: colors.grey,)),
              ],
            ),
          ),
        );
      },
    );
  }

}
