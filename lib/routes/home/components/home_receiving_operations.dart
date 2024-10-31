import 'package:aes/core/constants/colors.dart';
import 'package:aes/data/services/operations/file_operations.dart';
import 'package:aes/data/services/operations/key_operations.dart';
import 'package:aes/routes/components/qr_reader.dart';
import 'package:aes/ui/components/base_container.dart';
import 'package:aes/ui/components/on_tap_widget.dart';
import 'package:aes/ui/components/regular_text.dart';
import 'package:aes/ui/components/rich_text.dart';
import 'package:aes/ui/components/snackbar.dart';
import 'package:flutter/material.dart';

class ReceivingOperations extends StatefulWidget {
  const ReceivingOperations({super.key});

  @override
  State<ReceivingOperations> createState() => _ReceivingOperationsState();
}

class _ReceivingOperationsState extends State<ReceivingOperations> {
  final AppColors colors = AppColors();
  final KeyOperations keyOperations = KeyOperations();
  final FileOperations fileOperations = FileOperations();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RegularText(
              texts: "Alma İşlemleri",
              size: 15,
              color: theme.colorScheme.secondary,
              style: FontStyle.italic,
              weight: FontWeight.w600,
            ),
            InkWell(
              onTap: () {
                showSnackbar("Açıklama metni eklenmemiş",colors.greenDark,context);
              },
              child: BaseContainer(
                padding: 2,
                color: theme.colorScheme.secondary,
                radius: 50,
                child: Icon(Icons.question_mark_sharp, size: 14, color: theme.primaryColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildOperationCard("Dosya\n", "Al", Icons.file_open, "returnFile")),
            const SizedBox(width: 12),
            Expanded(child: _buildOperationCard("Anahtar\n", "Al", Icons.key_outlined, "returnKey")),
          ],
        ),
      ],
    );
  }

  Widget _buildOperationCard(String title, String action, IconData icon, String type) {
    return BaseContainer(
      padding: 0,
      child: onTapWidget(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QRCodeReadPage(type: type)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichTextWidget(
                fontSize: 15,
                texts: [title, action],
                colors: [Theme.of(context).colorScheme.secondary],
                fontFamilies: const ["FontMedium", "FontBold"],
              ),
              const SizedBox(height: 16),
              Align(
                alignment: icon == Icons.file_open ? Alignment.bottomRight : Alignment.bottomLeft,
                child: Icon(icon, size: 22, color: Theme.of(context).colorScheme.secondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}