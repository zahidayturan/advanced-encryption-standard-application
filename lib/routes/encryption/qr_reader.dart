import 'dart:io';
import 'package:aes/core/constants/colors.dart';
import 'package:aes/data/models/key_info.dart';
import 'package:aes/data/services/operations/key_operations.dart';
import 'package:aes/routes/encryption/generate_key.dart';
import 'package:aes/ui/components/loading.dart';
import 'package:aes/ui/components/regular_text.dart';
import 'package:flutter/material.dart';
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


        if(widget.type != "return" ){
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GenerateKey(codeOrPath: scanData.code!,type:widget.type)),
          );
        }else{
          List<String> parts = scanData.code!.split('/');
          if (parts.length >= 2) {
            String id = parts[0];
            String key = parts[1];
            KeyInfo? receivingKey = await keyOperations.getKeyInfoWithUser(id, key);
            Navigator.pop(context,receivingKey);
        }else{
            Navigator.pop(context,null);
          }
      }
    }});
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
