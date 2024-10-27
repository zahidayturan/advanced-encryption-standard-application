import 'package:aes/core/constants/colors.dart';
import 'package:aes/data/models/key_info.dart';
import 'package:aes/data/services/operations/key_operations.dart';
import 'package:aes/routes/encryption/components/e_page_app_bar.dart';
import 'package:aes/ui/components/base_container.dart';
import 'package:aes/ui/components/loading.dart';
import 'package:aes/ui/components/popup_menu.dart';
import 'package:aes/ui/components/regular_text.dart';
import 'package:aes/ui/components/rich_text.dart';
import 'package:aes/ui/components/shimmer_box.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AllKeysPage extends StatefulWidget {
  const AllKeysPage({super.key});

  @override
  State<AllKeysPage> createState() => _AllKeysPageState();
}

class _AllKeysPageState extends State<AllKeysPage> {
  AppColors colors = AppColors();
  KeyOperations keyOperations = KeyOperations();

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
                  const EPageAppBar(texts: "Üretilen Anahtarlar"),
                  FutureBuilder<List<KeyInfo>?>(
                    future: keyOperations.getAllKeyInfo(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return loadingContainer();
                      }
                      if (snapshot.hasError) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 18),
                            child: RegularText(texts: "Hata ile karşışaşıldı",size: 15),
                          ),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 18),
                            child: RegularText(texts: "Anahtar bulunamadı",size: 15),
                          ),
                        );
                      }
                      return keyContainer(snapshot.data!);
                    },
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget keyContainer(List<KeyInfo> keys) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: RegularText(texts: "${keys.length} anahtar bulundu",size: 12,),
          ),
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: keys.length,
          itemBuilder: (context, index) {
            var item = keys[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: BaseContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RegularText(
                          texts: item.name != "" ? item.name : "İsimsiz Anahtar",
                        ),
                        InkWell(
                          onTapDown: (TapDownDetails details) => _showMoreMenu(details, colors.blueMid, context, item),
                          child: BaseContainer(
                            padding: 2,
                            color: Theme.of(context).scaffoldBackgroundColor,
                            radius: 50,
                            child: Icon(
                              Icons.more_vert_rounded,
                              size: 20,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    RegularText(
                      texts: item.creationTime,
                    ),
                    RegularText(
                      texts: "AES-${item.bitLength} bit",
                    ),
                    RegularText(
                      texts: item.generateType,
                    ),
                    SizedBox(height: 8,),
                    Text(
                      item.key,
                      style: TextStyle(
                        fontSize: 9,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget loadingContainer() {
    return Column(
      children: List.generate(5, (index) => const Padding(
        padding: EdgeInsets.only(top: 12),
        child: ShimmerBox(height: 120),
      )),
    );
  }

  void _showMoreMenu(TapDownDetails details, Color color, BuildContext context, KeyInfo keyInfo) {
    showPopupMenu(
      details.globalPosition,
      Theme.of(context).colorScheme.primaryContainer,
      36,
      _popupMenuItems(context),
          (value) => _handlePopupMenuAction(value,keyInfo),context
    );
  }

  List<PopupMenuEntry<int>> _popupMenuItems(BuildContext context) {
    return [
      _buildMenuItem(context, Icons.qr_code_2_rounded, "QR ile paylaş", colors.blueMid, 1),
      _buildMenuItem(context, Icons.delete_outline_rounded, "Kalıcı olarak sil", colors.red, 2),
    ];
  }

  PopupMenuItem<int> _buildMenuItem(BuildContext context, IconData icon, String text, Color color, int value) {
    return PopupMenuItem<int>(
      value: value,
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontSize: 13, color: color)),
        ],
      ),
    );
  }

  Future<void> _handlePopupMenuAction(int? value, KeyInfo keyInfo) async {
    switch (value) {
      case 1:
        showQRGenerator(context,keyInfo);
        break;
      case 2:
          _showLoading("Anahtar siliniyor",context);
          await _deleteKey(keyInfo);
          _hideLoading();
          setState(() {});
        break;
    }
  }

  Future<void> _deleteKey(KeyInfo keyInfo) async {
    try {
      await KeyOperations().deleteKeyInfo(keyInfo.id!);
    } catch (e) {
      debugPrint("An error occurred: $e");
    }
  }

  void _showLoading(String message,BuildContext context) {
    LoadingDialog.showLoading(context, message: message);
  }

  void _hideLoading() {
    LoadingDialog.hideLoading(context);
  }

  void showQRGenerator(BuildContext context, KeyInfo keyInfo) {
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
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Container(width: 60,height: 4,decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: const BorderRadius.all(Radius.circular(50))
                    ),),
                    const SizedBox(height: 24),
                    RichTextWidget(
                      texts: const ["QR Kod ", "ile anahtarını paylaş"],
                      colors: [Theme.of(context).colorScheme.secondary],
                      fontFamilies: const ["FontBold", "FontMedium"],
                      fontSize: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Column(
                  children: [
                    RegularText(
                      texts: keyInfo.name != "" ? keyInfo.name : "İsimsiz Anahtar",
                      maxLines: 3,
                      size: 12,
                      align: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    QrImageView(
                      data: keyInfo.key,
                      version: QrVersions.auto,
                      size: 200.0,
                      backgroundColor: colors.grey,),
                    const SizedBox(height: 4),
                    RegularText(
                      texts: keyInfo.key,
                      maxLines: 3,
                      size: 9,
                      align: TextAlign.center,
                    ),
                    RegularText(
                      texts: keyInfo.creationTime,
                      size: 10,
                      align: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const RegularText(
                  texts: "Paylaşmak istediğiniz cihazda, QR ile anahtar al menüsünde bu kodu okutunuz.",
                  maxLines: 5,
                  size: 14,
                  align: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
