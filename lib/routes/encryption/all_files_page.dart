import 'package:aes/core/constants/colors.dart';
import 'package:aes/data/models/dto/key_file.dart';
import 'package:aes/data/models/file_info.dart';
import 'package:aes/data/models/key_info.dart';
import 'package:aes/data/services/operations/file_operations.dart';
import 'package:aes/routes/encryption/components/e_page_app_bar.dart';
import 'package:aes/ui/components/base_container.dart';
import 'package:aes/ui/components/loading.dart';
import 'package:aes/ui/components/popup_menu.dart';
import 'package:aes/ui/components/regular_text.dart';
import 'package:aes/ui/components/rich_text.dart';
import 'package:aes/ui/components/shimmer_box.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AllFilesPage extends StatefulWidget {
  final String fileType;
  const AllFilesPage({super.key, required this.fileType});

  @override
  State<AllFilesPage> createState() => _AllFilesPageState();
}

class _AllFilesPageState extends State<AllFilesPage> {
  AppColors colors = AppColors();
  FileOperations fileOperations = FileOperations();


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
                  EPageAppBar(texts: widget.fileType == "owned" ? "Yüklenen Dosyalar" : "Gelen Dosyalar"),
                  FutureBuilder<List<KeyFileInfo>?>(
                    future: fileOperations.getAllFileInfo(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return bodyLoading();
                      }
                      return Column(
                        children: [
                          Row(children: [
                            swapButton(snapshot.data!.isNotEmpty),
                            const SizedBox(width: 12,),
                            Expanded(child: searchBar(snapshot.data!.isNotEmpty))
                          ],),
                          const SizedBox(height: 12,),
                          files(snapshot.data!)
                        ],
                      );
                    },)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget swapButton(bool isActive){
    return BaseContainer(
      height: 32,
      padding: 8,
      radius: 50,
      child: Image.asset("assets/icons/sort.png",color: isActive ? Theme.of(context).colorScheme.onTertiary : colors.greyMid,height: 22),
    );
  }

  Widget searchBar(bool isActive){
    return BaseContainer(
        height: 32,
        padding: 0,
        radius: 50,
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: TextFormField(
            enabled: isActive,
            onTap: () {},
            style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.secondary
            ),
            readOnly: false,
            decoration: InputDecoration(
              hintText: "${widget.fileType == "owned" ? "Yüklenen" : "Gelen"} dosyalar içerisinde arayın",
              hintMaxLines: 1,
              isDense: true,
              hintStyle: TextStyle(
                  fontSize: 12,
                  color: isActive ?  Theme.of(context).colorScheme.secondary : colors.greyMid
              ),
              border: InputBorder.none,
              suffixIcon: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {

                  },
                  icon: Image.asset("assets/icons/search.png",height: 22,color: isActive ? Theme.of(context).colorScheme.onTertiary : colors.greyMid,
                  )
              ),
            ),
          ),
        )
    );
  }

  Widget files(List<KeyFileInfo> list){
    return Column(
      children: [
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: list.length,
          itemBuilder: (context, index) {
            var item = list[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: BaseContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: RegularText(texts: item.fileInfo.name,size: 13,family: "FontBold",maxLines: 2)),
                          const SizedBox(width: 8),
                          RichTextWidget(
                              texts: ["AES-",(item.keyInfo.bitLength)],
                              colors: [Theme.of(context).colorScheme.secondary],
                              fontSize: 12,
                              fontFamilies: const ["FontMedium","FontBold"]),

                        ]),
                    RegularText(texts: "${(item.fileInfo.size / 1024).toStringAsFixed(2)} KB",size: 11),
                    RegularText(texts: item.fileInfo.type,size: 11),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        RegularText(texts: item.fileInfo.creationTime,size: 12,align: TextAlign.end,),
                        InkWell(
                          onTapDown: (TapDownDetails details) => _showMoreMenu(details, colors.blueMid, context, item),
                          child: BaseContainer(
                              padding: 2,
                              color: Theme.of(context).scaffoldBackgroundColor,
                              radius: 50,
                              child: Icon(Icons.more_horiz_rounded,size: 20,color: Theme.of(context).colorScheme.secondary)),
                        )
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        ),
        Visibility(
            visible: list.isEmpty,
            child: const BaseContainer(
                height: 96,
                padding: 10,
                child: Center(child: RegularText(texts: "Dosya bulunamadı"))))
      ],
    );
  }

  void _showMoreMenu(TapDownDetails details, Color color, BuildContext context, KeyFileInfo keyFileInfo) {
    showPopupMenu(
        details.globalPosition,
        Theme.of(context).colorScheme.primaryContainer,
        36,
        _popupMenuItems(context),
            (value) => _handlePopupMenuAction(value,keyFileInfo),context
    );
  }

  List<PopupMenuEntry<int>> _popupMenuItems(BuildContext context) {
    return [
      _buildMenuItem(context, Icons.file_open_outlined, "Dosyanın şifresini çöz", Theme.of(context).colorScheme.secondary, 1),
      _buildMenuItem(context, Icons.send_outlined, "Dosyayı başkasına gönder", Theme.of(context).colorScheme.secondary, 2),
      _buildMenuItem(context, Icons.qr_code_2_rounded, "Dosyanın anahtarını paylaş", Theme.of(context).colorScheme.secondary, 3),
      _buildMenuItem(context, Icons.delete_outline_rounded, "Dosyayı kalıcı olarak sil", colors.red, 4),
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

  Future<void> _handlePopupMenuAction(int? value, KeyFileInfo info) async {
    switch (value) {
      case 3:
        showQRGenerator(context,info.keyInfo);
        break;
      case 4:
        _showLoading("Dosya siliniyor",context);
        await _deleteFile(info.fileInfo);
        _hideLoading();
        setState(() {});
        break;
    }
  }

  Future<void> _deleteFile(FileInfo fileInfo) async {
    try {
      await FileOperations().deleteFileInfo(fileInfo);
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

  Widget bodyLoading(){
    return Column(
      children: [
        Row(children: [
          ShimmerBox(height: 32,width:32, borderRadius: BorderRadius.circular(50)),
          const SizedBox(width: 12,),
          ShimmerBox(height: 32,borderRadius: BorderRadius.circular(50),)
        ],),
        const SizedBox(height: 12,),
        const ShimmerBox(height: 96),
      ],
    );
  }
}
