import 'dart:convert';
import 'dart:io';
import 'package:aes/core/constants/colors.dart';
import 'package:aes/data/get/get_storage_helper.dart';
import 'package:aes/data/models/dto/key_file.dart';
import 'package:aes/data/models/file_info.dart';
import 'package:aes/data/services/operations/file_operations.dart';
import 'package:aes/routes/components/e_page_app_bar.dart';
import 'package:aes/ui/components/base_container.dart';
import 'package:aes/ui/components/date_format.dart';
import 'package:aes/ui/components/loading.dart';
import 'package:aes/ui/components/popup_menu.dart';
import 'package:aes/ui/components/regular_text.dart';
import 'package:aes/ui/components/rich_text.dart';
import 'package:aes/ui/components/shimmer_box.dart';
import 'package:aes/ui/components/text_field.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';

class AllFilesPage extends StatefulWidget {
  final String fileType;
  const AllFilesPage({super.key, required this.fileType});

  @override
  State<AllFilesPage> createState() => _AllFilesPageState();
}

enum SortOrder { newest, oldest, largest, smallest }

class _AllFilesPageState extends State<AllFilesPage> {
  AppColors colors = AppColors();
  FileOperations fileOperations = FileOperations();
  final _tempKeyController = TextEditingController();
  bool dataChanged = false;

  TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  SortOrder sortOrder = SortOrder.newest;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<KeyFileInfo> filterFiles(List<KeyFileInfo> files, String query) {
    if (query.isNotEmpty) {
      files = files.where((file) => file.fileInfo.name.contains(query)).toList();
    }
    if (sortOrder == SortOrder.newest) {
      files.sort((a, b) => b.fileInfo.creationTime.compareTo(a.fileInfo.creationTime));
    } else if(sortOrder == SortOrder.oldest) {
      files.sort((a, b) => a.fileInfo.creationTime.compareTo(b.fileInfo.creationTime));
    }else if(sortOrder == SortOrder.largest){
      files.sort((a, b) => b.fileInfo.size.compareTo(a.fileInfo.size));
    }else {
      files.sort((a, b) => a.fileInfo.size.compareTo(b.fileInfo.size));
    }
    return files;
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
                    EPageAppBar(texts: widget.fileType == "owned" ? "Yüklenen Dosyalar" : "Gelen Dosyalar", dataChanged: dataChanged),
                    FutureBuilder<List<KeyFileInfo>?>(
                      future: fileOperations.getAllFileInfo(widget.fileType),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return bodyLoading();
                        }
                        List<KeyFileInfo> filteredFiles = filterFiles(snapshot.data ?? [], searchQuery);
                        return Column(
                          children: [
                            SizedBox(
                              height: 20,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: RegularText(texts: "${filteredFiles.length} dosya bulundu",size: 12,),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                swapButton(filteredFiles.isNotEmpty),
                                const SizedBox(width: 12),
                                Expanded(child: searchBar(snapshot.data!.isNotEmpty)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            files(filteredFiles),
                          ],
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
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
                  texts: "Dosyaları sırala",
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
                ),
                ListTile(
                  title: const RegularText(texts: "Boyutuna göre büyükten küçüğe sırala",size: 14,),
                  onTap: () {
                    setState(() {
                      sortOrder = SortOrder.largest;
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const RegularText(texts: "Boyutune göre küçükten büyüğe sırala",size: 14,),
                  onTap: () {
                    setState(() {
                      sortOrder = SortOrder.smallest;
                    });
                    Navigator.pop(context);
                  },
                ),
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
                          Expanded(child: RegularText(texts: item.fileInfo.name != "" ? item.fileInfo.name : "İsimsiz Dosya",size: 13,family: "FontBold",maxLines: 2)),
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
                    RegularText(texts: item.fileInfo.keyId != "tempKey" ? "Çözücü Anahtarı Hazır" : "Anahtarı Kaydedilmemiş",size: 11),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(right: 4),
                              child: RegularText(texts: "Şifrelendi",style: FontStyle.italic,size: 11,family: "FontLight",),
                            ),
                            RegularText(
                                texts: formatDateTime(item.fileInfo.creationTime),size: 12
                            ),
                          ],
                        ),
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
      _buildMenuItem(context, Icons.file_open_outlined, "Dosyayı çöz ve aç", colors.blueMid, 1),
      _buildMenuItem(context, Icons.open_in_browser_outlined, "Dosyanın şifresini çöz", Theme.of(context).colorScheme.secondary, 2),
      _buildMenuItem(context, Icons.send_outlined, "Dosyayı başkasına gönder", Theme.of(context).colorScheme.secondary, 3),
      _buildMenuItem(context, Icons.qr_code_2_rounded, "Dosyanın anahtarını paylaş", Theme.of(context).colorScheme.secondary, 4),
      _buildMenuItem(context, Icons.delete_outline_rounded, "Dosyayı kalıcı olarak sil", colors.red, 5),
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
    String? uuid =  GetLocalStorage().getUUID();
    if (uuid == null || uuid.isEmpty) {
      throw Exception("UUID bulunamadı.");
    }
    switch (value) {
      case 1:
        if(info.keyInfo.id != "tempKey"){
          await _openFile(info);
        }else{
          showInputKeyMenu("open",info);
        }
        break;
      case 2:
        if(info.keyInfo.id != "tempKey"){
          _showLoading("Bilgiler alınıyor");
          List<String>? list = await _getFileInfo(info);
          _hideLoading();
          showFileByte(info,list!.first,list.last);
        }else{
          showInputKeyMenu("info",info);
        }
        break;
      case 3:
        showQRGenerator(context,info,false,uuid);
        break;
      case 4:
        if(info.keyInfo.id != "tempKey"){
          showQRGenerator(context,info,true,uuid);
        }else{
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: RegularText(texts: "Bu dosyanın anahtarı kayıtlı değil", color: colors.grey),
              backgroundColor: colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        break;
      case 5:
        _showLoading("Dosya siliniyor");
        await _deleteFile(info.fileInfo);
        _hideLoading();
        setState(() {});
        break;
    }
  }

  Future<void> _deleteFile(FileInfo fileInfo) async {
    try {
      await FileOperations().deleteFileInfo(fileInfo);
      dataChanged = true;
    } catch (e) {
      debugPrint("An error occurred: $e");
    }
  }

  Future<void> _openFile(KeyFileInfo info) async {
    try {
      if (await Permission.storage.isDenied) {
        await Permission.storage.request();
      }

      if (await Permission.manageExternalStorage.isDenied) {
        await Permission.manageExternalStorage.request();
      }
      _showLoading("Dosya çözülüyor");

      List<int>? decrypted = await fileOperations.getDecryptedFile(info.fileInfo, info.keyInfo.key);
      if (decrypted != null && decrypted.isNotEmpty) {
        debugPrint(decrypted.length.toString());
        debugPrint(decrypted.toString());
        final tempDir = await getTemporaryDirectory();
        final tempFilePath = '${tempDir.path}/${info.fileInfo.originalName}';
        File tempFile = File(tempFilePath);

        tempFile.writeAsBytesSync(decrypted);
        _hideLoading();

        await OpenFile.open(tempFilePath);
      }
    } catch (e) {
      debugPrint("An error occurred: $e");
    }
  }

  Future<List<String>?> _getFileInfo(KeyFileInfo info) async {
    try {
      List<int>? encrypted = await fileOperations.getEncryptedFile(info.fileInfo);
      List<int>? decrypted = await fileOperations.getDecryptedFile(info.fileInfo, info.keyInfo.key);
      String encryptedBase64 = base64Encode(encrypted!.take(1500).toList());
      String decryptedBase64 = base64Encode(decrypted!.take(1500).toList());
      return [encryptedBase64, decryptedBase64];
    } catch (e) {
      debugPrint("An error occurred: $e");
      return null;
    }
  }

  void _showLoading(String message) {
    LoadingDialog.showLoading(context, message: message);
  }

  void _hideLoading() {
    LoadingDialog.hideLoading(context);
  }

  void showQRGenerator(BuildContext context, KeyFileInfo info,bool isKey,String uuid) {
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
                      texts: ["QR Kod ", isKey ? "ile anahtarını paylaş" : "ile dosyanı paylaş"],
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
                      texts: isKey ? (info.keyInfo.name != "" ? info.keyInfo.name : "İsimsiz Anahtar") :
                      (info.fileInfo.name != "" ? info.fileInfo.name : "İsimsiz Dosya"),
                      maxLines: 3,
                      size: 12,
                      align: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    QrImageView(
                      data: isKey ? "$uuid/${info.keyInfo.id!}" : "$uuid/${info.fileInfo.id!}",
                      version: QrVersions.auto,
                      size: 200.0,
                      backgroundColor: colors.grey,),
                    const SizedBox(height: 4),
                    RegularText(
                      texts: isKey ? info.keyInfo.key : info.fileInfo.type,
                      maxLines: 3,
                      size: 9,
                      align: TextAlign.center,
                    ),
                    RegularText(
                      texts: formatDateTime(isKey ? info.keyInfo.creationTime : info.fileInfo.creationTime),
                      size: 10,
                      align: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                RegularText(
                  texts: isKey ? "Paylaşmak istediğiniz cihazda, anahtar al menüsünde bu kodu okutunuz.":
                  "Paylaşmak istediğiniz cihazda, dosya al menüsünde bu kodu okutunuz.",
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

  void showFileByte(KeyFileInfo info,String encrypted,String decrypted) {
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: RichTextWidget(
                        texts: const ["Şifreli ", "dosya (ilk 1500)"],
                        colors: [Theme.of(context).colorScheme.secondary],
                        fontFamilies: const ["FontBold", "FontMedium"],
                        fontSize: 13
                      ),
                    ),
                    Expanded(
                      child: RichTextWidget(
                        texts: const ["Çözülmüş ", "dosya (ilk 1500)"],
                        colors: [Theme.of(context).colorScheme.secondary],
                        fontFamilies: const ["FontBold", "FontMedium"],
                        fontSize: 13
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(encrypted,style: const TextStyle(fontSize: 11),)),
                    const SizedBox(width: 10),
                    Expanded(child: Text(decrypted,style: const TextStyle(fontSize: 11),)),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void showInputKeyMenu(String returnType,KeyFileInfo info) {
    showDialog(
        context: context,
        barrierColor: Theme.of(context).colorScheme.secondary.withOpacity(0.075),
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            contentPadding: const EdgeInsets.all(8),
            insetPadding: const EdgeInsets.all(12),
            content: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text(
                         "Dosyayı açmak için anahtar sağlayın",
                       style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close_rounded),
                      alignment: Alignment.centerRight,
                    )
                  ],
                ),
                BaseContainer(
                    child:
                    Row(
                      children: [
                        Expanded(
                          child: FullTextField(
                              myController: _tempKeyController,
                              fieldName: "Anahtar",
                              hintText: "Anahtarı giriniz",
                              myIcon: Icons.key_rounded,
                              border: false,
                              readOnly: false),
                        ),
                        const SizedBox(width: 8,),
                        ElevatedButton(
                          onPressed: () async {
                            int decodedInputLength = base64Decode(_tempKeyController.text).length;
                            if(decodedInputLength == 16 ||
                                decodedInputLength == 24 ||
                                decodedInputLength == 32){
                              setState(() {
                                String userKey = _tempKeyController.text.toString();
                                info.keyInfo.key = userKey;
                              });
                              Navigator.pop(context);
                              if(returnType == "open"){
                                _openFile(info);
                              }else if(returnType == "info"){
                                _showLoading("Bilgiler alınıyor");
                                List<String>? list = await _getFileInfo(info);
                                _hideLoading();
                                showFileByte(info,list!.first,list.last);
                              }
                            }else{
                              var snackBar = SnackBar(content: Text('Geçersiz Anahtar Uzunluğu',style: TextStyle(color: colors.grey),),backgroundColor: colors.red,);
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(colors.black),
                            padding: const MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 4)),
                          ),
                          child: RegularText(
                            texts: "Aç", color: colors.grey,
                          ),
                        )

                      ],
                    )),
                const SizedBox(height: 8,),

              ],
            ),
          );
        });
  }

  Widget bodyLoading(){
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
        const SizedBox(height: 12,),
        const ShimmerBox(height: 96),
        const SizedBox(height: 12,),
        const ShimmerBox(height: 96),
        const SizedBox(height: 12,),
        const ShimmerBox(height: 96)
      ],
    );
  }
}
