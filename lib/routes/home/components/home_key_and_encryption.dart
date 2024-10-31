import 'dart:io';
import 'package:aes/core/constants/colors.dart';
import 'package:aes/data/get/get_storage_helper.dart';
import 'package:aes/data/services/operations/key_operations.dart';
import 'package:aes/routes/key/all_keys_page.dart';
import 'package:aes/routes/file/file_encryption.dart';
import 'package:aes/routes/key/generate_key.dart';
import 'package:aes/routes/components/qr_reader.dart';
import 'package:aes/routes/components/voice_recorder.dart';
import 'package:aes/ui/components/base_container.dart';
import 'package:aes/ui/components/dropdown_menu.dart';
import 'package:aes/ui/components/on_tap_widget.dart';
import 'package:aes/ui/components/regular_text.dart';
import 'package:aes/ui/components/rich_text.dart';
import 'package:aes/ui/components/shimmer_box.dart';
import 'package:aes/ui/components/snackbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class HomeKeyAndEncryption extends StatefulWidget {

  const HomeKeyAndEncryption({super.key,});

  @override
  State<HomeKeyAndEncryption> createState() => _HomeKeyAndEncryptionState();
}

class _HomeKeyAndEncryptionState extends State<HomeKeyAndEncryption> {

  AppColors colors = AppColors();
  final localStorage = GetLocalStorage();
  final keyOperations = KeyOperations();

  List<String> bitLengthList = ["128 bit", "192 bit", "256 bit"];
  int initialIndex = 2;

  @override
  void initState() {
    super.initState();
    _loadInitialBitLength();
  }

  Future<void> _loadInitialBitLength() async {
    int savedBitLength = localStorage.getBitLength();
    if (savedBitLength == 128) {
      setState(() {
        initialIndex = 0;
      });
    }else if(savedBitLength == 192){
      setState(() {
        initialIndex = 1;
      });
    }
  }

  Future<void> pickAndEncryptFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.isNotEmpty) {
      PlatformFile file = result.files.first;
      if (file.path != null) {
        final fileSize = File(file.path!).lengthSync();
        const maxSizeInBytes = 20 * 1024 * 1024; // 20 MB

        if (fileSize > maxSizeInBytes) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Seçtiğiniz dosya 20 MB'dan büyük. Lütfen daha küçük bir dosya seçin."),
            ),
          );
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FileEncryption(filePath: file.path)),
        );
      } else {
        debugPrint("Dosya yolu bulunamadı.");
      }
    } else {
      debugPrint("Dosya seçilmedi.");
    }
  }

  Future<String?> pickImagePath() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null && result.files.isNotEmpty) {
      PlatformFile file = result.files.first;
      if (file.path != null) {
        return file.path;
      } else {
        debugPrint("Dosya yolu bulunamadı.");
        return null;
      }
    } else {
      debugPrint("Dosya seçilmedi.");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RegularText(texts: "Anahtar ve Şifreleme İşlemleri",size: 15,color: Theme.of(context).colorScheme.tertiary,style: FontStyle.italic,weight: FontWeight.w600,),
            onTapWidget(
                onTap: (){
                  showSnackbar("Açıklama metni eklenmemiş",colors.greenDark,context);
                },
                child: BaseContainer(
                    padding: 2, color: Theme.of(context).colorScheme.tertiaryContainer, radius: 50,
                    child: Icon(Icons.question_mark_sharp,size: 14,color: colors.grey)))
          ],
        ),
        const SizedBox(height: 12,),
        FutureBuilder(
          future: keyOperations.getAllKeyInfo(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return bodyLoading();
            }
            return  Column(
              children: [
                bitSize(),
                const SizedBox(height: 12,),
                Row(children: [
                  Expanded(
                      flex: 4,
                      child: allKeys(snapshot.data!.length)),
                  const SizedBox(width: 12,),
                  Expanded(
                      flex: 5,
                      child: generateKey(snapshot.data!.isEmpty))
                ],),
                const SizedBox(height: 12,),
                encryptFile(context)
              ],);
          },),
      ],
    );
  }

  final TextEditingController _bitSizeController = TextEditingController();
  Widget bitSize(){
    return BaseContainer(
      height: 36,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const RegularText(texts: "Güvenlik Seviyesi",size: 13,),
            CustomDropdownMenu(
              list: bitLengthList,
              onChanged: (value) async {
                int newBitLength = 256;
                if(value.contains("192")){
                  newBitLength = 192;
                }else if(value.contains("128")){
                  newBitLength = 128;
                }
                await localStorage.saveBitLength(newBitLength);
              },
              textColor: colors.white,
              dropdownColor: Theme.of(context).colorScheme.tertiaryContainer,
              fontSize: 13,
              padding: 16,
              initialIndex: initialIndex,
              controller: _bitSizeController,
            )
          ],
        ));
  }

  Widget bodyLoading(){
    return const Column(
      children: [
        ShimmerBox(height: 36),
        SizedBox(height: 12,),
        Row(children: [
          Expanded(
              flex: 4,
              child: ShimmerBox(height: 132)),
          SizedBox(width: 12,),
          Expanded(
              flex: 5,
              child: ShimmerBox(height: 132))
        ],),
        SizedBox(height: 12,),
        ShimmerBox(height: 84)
      ],
    );
  }

  Widget allKeys(int allKeyCount){
    return BaseContainer(
        height: 132,
        padding: 0,
        child: Stack(
          children: [
        Positioned(
          left: -6,
          bottom: -6,
          child: Image.asset("assets/icons/allKeys.png",height: 56,color: Theme.of(context).scaffoldBackgroundColor),
        ),
        onTapWidget(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AllKeysPage()),
              );
              if (result == 'updated') {
                setState(() {
                });
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichTextWidget(
                      fontSize: 15,
                      texts: const ["Üretilen\n","Anahtarlar"],
                      colors: [Theme.of(context).colorScheme.tertiary],
                      fontFamilies: const ["FontMedium","FontBold"]
                  ),
                  Align(
                      alignment: Alignment.bottomRight,
                      child: RegularText(texts: allKeyCount == 0 ? "Üretilmiş\nanahtar\nyok" : "Üretilmiş\nanahtar\nsayısı $allKeyCount",size: 11,align: TextAlign.end,))
                ],
              ),
            )
        ),
      ],
    ));
  }

  Widget generateKey(bool activeKey){
    return BaseContainer(
        height: 132,
        padding: 0,
        child: Stack(
          children: [
            Positioned(
              left: 14,
              bottom: -14,
              child: Image.asset("assets/icons/generateKey.png",height: 102,color: Theme.of(context).scaffoldBackgroundColor),
            ),
            onTapWidget(
                onTap: (){
                  showProductionOptions(context);
                },
                child:  Padding(
                padding: const EdgeInsets.all(10),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.vpn_key_outlined,
                            size: 22,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          RichTextWidget(
                              texts: const ["Anahtar\n","Üret"],
                              fontSize: 15,
                              align: TextAlign.end,
                              colors: [Theme.of(context).colorScheme.tertiary],
                              fontFamilies: const ["FontMedium","FontBold"]),
                        ],
                      ),
                      RegularText(texts: activeKey ? "Aktif\nanahtar\nyok" : "Aktif\nanahtar\nbulundu",size: 11,align: TextAlign.end,)
                    ],
                  ),
                ),
              )
            )
          ],
        ));
  }

  Widget encryptFile(BuildContext context) {
    return BaseContainer(
      padding: 0,
      child: Stack(
        children: [
          Positioned(
            right: 54,
            bottom: 4,
            child: RotationTransition(
                turns: const AlwaysStoppedAnimation(30 / 360),
                child: Image.asset(
                  "assets/icons/addFile.png",
                  height: 90,
                  color: Theme.of(context).scaffoldBackgroundColor,
                )),
          ),
          GestureDetector(
            onTap: () {
              pickAndEncryptFile(context);
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichTextWidget(
                        texts: const ["Dosya ", "Şifrele"],
                        fontSize: 15,
                        colors: [Theme.of(context).colorScheme.tertiary],
                        fontFamilies: const ["FontMedium", "FontBold"],
                      ),
                      Icon(
                        Icons.add_circle_outline_rounded,
                        size: 24,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Center(
                    child: RegularText(
                      texts: "Dosya seçmek için dokunun",
                      size: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showProductionOptions(BuildContext context) {
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
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(width: 60,height: 4,decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: const BorderRadius.all(Radius.circular(50))
                  ),),
                ),
                const SizedBox(height: 24),
                RichTextWidget(
                    texts: const ["Anahtar ","Üretim Yöntemleri"],
                    colors: [Theme.of(context).colorScheme.secondary],
                    fontFamilies: const ["FontMedium","FontBold"],
                    fontSize: 16,
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Icon(Icons.qr_code_2_rounded,color: Theme.of(context).colorScheme.secondary,),
                  title: const RegularText(texts: "QR Kod İle Üret", size: 15,),
                  onTap: () async {
                    Navigator.pop(context);
                    final result = await Navigator.push(
                      context,
                      //MaterialPageRoute(builder: (context) => const GenerateKey(codeOrPath: "helloworld",type: "qr",)),
                      MaterialPageRoute(builder: (context) => QRCodeReadPage(type: "qr")),
                    );
                    if (result == 'updated') {
                      setState(() {});
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.qr_code_scanner_rounded,color: Theme.of(context).colorScheme.secondary,),
                  title: const RegularText(texts: "Barkod İle Üret", size: 15,),
                  onTap: () async {
                    Navigator.pop(context);
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const QRCodeReadPage(type: "barcode")),
                    );
                    if (result == 'updated') {
                      setState(() {});
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.image_outlined,color: Theme.of(context).colorScheme.secondary,),
                  title: const RegularText(texts: "Görüntü İle Üret", size: 15,),
                  onTap: () async {
                    String? imagePath = await pickImagePath();
                    debugPrint(imagePath);
                    if (imagePath != null) {
                      Navigator.pop(context);
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GenerateKey(codeOrPath: imagePath, type: "image")),
                      );
                      if (result == 'updated') {
                        setState(() {});
                      }
                    }else{
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: RegularText(texts: "Görüntü dosyası seçilirken bir hata oluştu",color: colors.grey,),backgroundColor: colors.red,behavior: SnackBarBehavior.floating,),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.mic_none_rounded,color: Theme.of(context).colorScheme.secondary,),
                  title: const RegularText(texts: "Ses İle Üret", size: 15,),
                  onTap: () async {
                    Navigator.pop(context);
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const VoiceProductionPage()),
                    );
                    if (result == 'updated') {
                      setState(() {});
                    }

                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}