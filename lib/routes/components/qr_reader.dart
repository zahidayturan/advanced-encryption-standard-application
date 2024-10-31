import 'dart:io';
import 'package:aes/core/constants/colors.dart';
import 'package:aes/data/services/operations/file_operations.dart';
import 'package:aes/data/services/operations/key_operations.dart';
import 'package:aes/routes/key/generate_key.dart';
import 'package:aes/ui/components/loading.dart';
import 'package:aes/ui/components/regular_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRCodeReadPage extends StatefulWidget {
  final String type;
  const QRCodeReadPage({super.key, required this.type});

  @override
  State<QRCodeReadPage> createState() => _QRCodeReadPageState();
}

class _QRCodeReadPageState extends State<QRCodeReadPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  final AppColors colors = AppColors();
  final KeyOperations keyOperations = KeyOperations();
  final FileOperations fileOperations = FileOperations();

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
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          _buildResultContainer(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      iconTheme: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      title: RegularText(
        texts: widget.type == "barcode" ? "Barkod Okuyucu" : "QR Kod Okuyucu",
        size: 17,
      ),
    );
  }

  Widget _buildResultContainer() {
    return Expanded(
      flex: 1,
      child: Container(
        color: result != null ? colors.green : Theme.of(context).scaffoldBackgroundColor,
        child: Center(
          child: RegularText(
            texts: result != null
                ? 'Kod Okundu, Bekleyiniz'
                : widget.type == "barcode"
                ? "Barkodu Okutunuz"
                : 'QR Kodu Okutunuz',
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() => this.controller = controller);

    controller.scannedDataStream.listen((scanData) async {
      if (!mounted || result != null) return;
      setState(() => result = scanData);

      if (scanData.code != null) {
        await Future.delayed(const Duration(milliseconds: 1500));
        if (!mounted) return;

        switch (widget.type) {
          case "qr":
          case "barcode":
            _navigateToGenerateKey(scanData.code!);
            break;
          case "returnKey":
            await _processReturnKey(scanData.code!);
            break;
          case "returnFile":
            await _processReturnFile(scanData.code!);
            break;
          default:
            Navigator.pop(context);
        }
      }
    });
  }

  void _navigateToGenerateKey(String code) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GenerateKey(codeOrPath: code, type: widget.type),
      ),
    );
  }

  Future<void> _processReturnKey(String code) async {
    final parts = code.split('/');
    if (parts.length < 2) return _showErrorSnackbar("Bir anahtar bulunamadı");

    final id = parts[0], kid = parts[1];
    try {
      final receivingKey = await keyOperations.getKeyInfoWithUser(id, kid);
      receivingKey != null
          ? _showQRGenerator(receivingKey.name, receivingKey.key, "AES-${receivingKey.bitLength}", () async {
        await keyOperations.insertKeyInfo(receivingKey);
      })
          : _showErrorSnackbar("Bir anahtar bulunamadı");
    } catch (e) {
      _showErrorSnackbar("Bir hata oluştu: $e");
    }
  }

  Future<void> _processReturnFile(String code) async {
    final parts = code.split('/');
    if (parts.length < 2) return _showErrorSnackbar("Bir dosya bulunamadı");

    final id = parts[0], fid = parts[1];
    try {
      final receivingFile = await fileOperations.getFileInfoWithUser(id, fid);
      receivingFile != null
          ? _showQRGenerator(receivingFile.name, receivingFile.type, "${(receivingFile.size / 1024).toStringAsFixed(2)} KB", () async {
        await fileOperations.insertReceivingFile(receivingFile);
      })
          : _showErrorSnackbar("Bir dosya bulunamadı");
    } catch (e) {
      _showErrorSnackbar("Bir hata oluştu: $e");
    }
  }

  void _showQRGenerator(String name, String detail, String subdetail, Function onSave) {
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
                Container(
                  width: 60,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                  ),
                ),
                const SizedBox(height: 24),
                RegularText(
                  texts: "Bilgi alındı",
                  color: Theme.of(context).colorScheme.secondary,
                  family: "FontBold",
                  size: 16,
                ),
                const SizedBox(height: 4),
                RegularText(
                  texts: name.isNotEmpty ? name : "İsimsiz",
                  maxLines: 3,
                  size: 12,
                  align: TextAlign.center,
                ),
                const SizedBox(height: 4),
                RegularText(
                  texts: detail,
                  size: 9,
                  align: TextAlign.center,
                ),
                const SizedBox(height: 4),
                RegularText(
                  texts: subdetail,
                  size: 9,
                  align: TextAlign.center,
                ),
                const SizedBox(height: 8),
                _buildActionButton("Bilgiyi kaydet ve çık", onSave),
                const SizedBox(height: 8),
                _buildActionButton("Bilgiyi kopyala ve çık", () {
                  Clipboard.setData(ClipboardData(text: detail));
                  _showSnackbar("Bilgi panoya kopyalandı", colors.green);
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  ElevatedButton _buildActionButton(String text, Function onPressed) {
    return ElevatedButton(
      onPressed: () async {
        LoadingDialog.showLoading(context, message: text);
        await onPressed();
        LoadingDialog.hideLoading(context);
        Navigator.of(context).pop();
        setState(() {});
      },
      child: RegularText(texts: text, color: colors.grey),
    );
  }

  void _showErrorSnackbar(String message) {
    _showSnackbar(message, colors.red);
  }

  void _showSnackbar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: RegularText(texts: message, color: colors.grey),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}