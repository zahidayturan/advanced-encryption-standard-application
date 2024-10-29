import 'package:aes/core/constants/colors.dart';
import 'package:aes/data/models/key_info.dart';
import 'package:aes/data/services/operations/key_operations.dart';
import 'package:aes/routes/encryption/components/e_page_app_bar.dart';
import 'package:aes/ui/components/base_container.dart';
import 'package:aes/ui/components/date_format.dart';
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

enum SortOrder { newest, oldest }

class _AllKeysPageState extends State<AllKeysPage> {
  AppColors colors = AppColors();
  KeyOperations keyOperations = KeyOperations();
  bool dataChanged = false;

  TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  SortOrder sortOrder = SortOrder.newest;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<KeyInfo> filterKeys(List<KeyInfo> keys, String query) {
    if (query.isNotEmpty) {
      keys = keys.where((file) => file.name.contains(query)).toList();
    }
    if (sortOrder == SortOrder.newest) {
      keys.sort((a, b) => b.creationTime.compareTo(a.creationTime));
    } else {
      keys.sort((a, b) => a.creationTime.compareTo(b.creationTime));
    }
    return keys;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, dataChanged ? 'updated' : '');
          return false;
        },
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
                    EPageAppBar(texts: "Üretilen Anahtarlar",dataChanged: dataChanged,),
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
                        List<KeyInfo> filteredKeys = filterKeys(snapshot.data ?? [], searchQuery);
                        return Column(
                          children: [
                            SizedBox(
                              height: 20,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: RegularText(texts: "${filteredKeys.length} anahtar bulundu",size: 12,),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                swapButton(filteredKeys.isNotEmpty),
                                const SizedBox(width: 12),
                                Expanded(child: searchBar(snapshot.data!.isNotEmpty)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            keyContainer(filteredKeys),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String getTypeName(String shortName){
    if(shortName == "qr"){
      return "QR Kod ile";
    }else if(shortName == "barcode"){
      return "Barkod ile";
    }else if(shortName == "image"){
      return "Görüntü ile";
    }else{
      return "Ses ile";
    }
  }

  Widget keyContainer(List<KeyInfo> keys) {
    return Column(
      children: [
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
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: RegularText(texts: "Üretildi",style: FontStyle.italic,size: 11,family: "FontLight",),
                        ),
                        RegularText(
                          texts: formatDateTime(item.creationTime),size: 13
                        ),
                      ],
                    ),
                    SizedBox(height: 8,),
                    RegularText(
                      texts: "AES-${item.bitLength} bit",size: 12
                    ),
                    RegularText(
                      texts: "${getTypeName(item.generateType)} üretildi",size: 10
                    ),
                    const SizedBox(height: 8,),
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
        Visibility(
            visible: keys.isEmpty,
            child: const BaseContainer(
                height: 96,
                padding: 10,
                child: Center(child: RegularText(texts: "Anahtar bulunamadı"))))
      ],
    );
  }

  Widget swapButton(bool isActive) {
    return InkWell(
      onTap: () {
        if(isActive){
          _showSortMenu();
        }
      },
      child: BaseContainer(
        height: 32,
        padding: 9,
        radius: 50,
        child: Image.asset(
          "assets/icons/sort.png",
          color: isActive ? Theme.of(context).colorScheme.secondary : colors.greyMid,
          height: 20,
        ),
      ),
    );
  }

  void _showSortMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      barrierColor: Theme.of(context).colorScheme.secondary.withOpacity(0.075),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 60,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.green,
                      borderRadius: const BorderRadius.all(Radius.circular(50)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                RegularText(
                  texts: "Anahtarları sırala",
                  size: 16,
                  weight: FontWeight.bold,
                  color: colors.green,
                ),
                const SizedBox(height: 8),
                ListTile(
                  title: const RegularText(texts: "Tarihine göre yeniden eskiye sırala",size: 14,),
                  onTap: () {
                    setState(() {
                      sortOrder = SortOrder.newest;
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const RegularText(texts: "Tarihine göre eskiden yeniye sırala",size: 14,),
                  onTap: () {
                    setState(() {
                      sortOrder = SortOrder.oldest;
                    });
                    Navigator.pop(context);
                  },
                )
              ],
            ),
          ),
        );
      },
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
            controller: searchController,
            enabled: isActive,
            onEditingComplete: () {
              setState(() {
                searchQuery = searchController.text;
              });
            },
            style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.secondary
            ),
            readOnly: false,
            decoration: InputDecoration(
              hintText: "Anahtarlarınız içerisinde arayın",
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
                    setState(() {
                      searchQuery = searchController.text;
                    });
                  },
                  icon: Image.asset("assets/icons/search.png",height: 22,color: isActive ? Theme.of(context).colorScheme.secondary : colors.greyMid,
                  )
              ),
            ),
          ),
        )
    );
  }

  Widget loadingContainer() {
    return Column(
      children: [
        const Align(
            alignment: Alignment.centerRight,
            child: ShimmerBox(height: 20,width: 120)),
        const SizedBox(height: 12),
        Row(children: [
          ShimmerBox(height: 32,width:32, borderRadius: BorderRadius.circular(50)),
          const SizedBox(width: 12,),
          Expanded(child: ShimmerBox(height: 32,borderRadius: BorderRadius.circular(50),))
        ],),
        SizedBox(height: 4,),
        Column(
          children: List.generate(5, (index) => const Padding(
            padding: EdgeInsets.only(top: 8),
            child: ShimmerBox(height: 108),
          )),
        ),
      ],
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
      dataChanged = true;
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
            physics: const BouncingScrollPhysics(),
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
                      texts: formatDateTime(keyInfo.creationTime),
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
