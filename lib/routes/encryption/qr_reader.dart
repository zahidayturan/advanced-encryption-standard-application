import 'dart:io';
import 'package:aes/core/constants/colors.dart';
import 'package:aes/routes/encryption/generate_key.dart';
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
          title: RegularText(texts: widget.type == "qr" ? "QR Kod Okuyucu" : "Barkod Okuyucu",size: 17)),
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
                    : RegularText(texts: widget.type == "qr" ? 'QR Kodu Okutunuz' : "Barkodu Okutunuz"),
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

        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GenerateKey(codeOrPath: scanData.code!,type:widget.type)),
        );
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
