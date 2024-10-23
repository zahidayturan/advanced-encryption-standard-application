import 'dart:io';
import 'package:aes/core/constants/colors.dart';
import 'package:aes/routes/encryption/generate_key.dart';
import 'package:aes/ui/components/regular_text.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRViewExample extends StatefulWidget {
  const QRViewExample({super.key});

  @override
  State<QRViewExample> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  AppColors colors = AppColors();

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          iconTheme: IconThemeData(color: Theme.of(context).colorScheme.secondary),
          title: const RegularText(texts: "QR Kod Okuyucu",size: 17)),
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
                    : const RegularText(texts: 'QR Kodu Okutunuz'),
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
          MaterialPageRoute(builder: (context) => GenerateKey(code: scanData.code!,type: "qr",)),
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
