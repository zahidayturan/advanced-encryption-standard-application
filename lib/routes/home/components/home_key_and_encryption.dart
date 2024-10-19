import 'package:aes/core/constants/colors.dart';
import 'package:aes/ui/components/base_container.dart';
import 'package:aes/ui/components/dropdown_menu.dart';
import 'package:aes/ui/components/regular_text.dart';
import 'package:aes/ui/components/rich_text.dart';
import 'package:flutter/material.dart';

class HomeKeyAndEncryption extends StatefulWidget {
  const HomeKeyAndEncryption({super.key});

  @override
  State<HomeKeyAndEncryption> createState() => _HomeKeyAndEncryptionState();
}

class _HomeKeyAndEncryptionState extends State<HomeKeyAndEncryption> {

  AppColors colors = AppColors();

  @override
  Widget build(BuildContext context) {
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RegularText(texts: "Anahtar ve Şifreleme İşlemleri",size: 15,color: colors.greenDark,style: FontStyle.italic,weight: FontWeight.w600,),
        const SizedBox(height: 12,),
        bitSize(),
        const SizedBox(height: 12,),
        Row(children: [
          Expanded(
              flex: 2,
              child: allKeys()),
          const SizedBox(width: 12,),
          Expanded(
              flex: 3,
              child: generateKey())
        ],),
        const SizedBox(height: 12,),
        encryptFile()

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
              list: ["128 bit","192 bit","256 bit"],
              textColor: colors.white,
              dropdownColor: colors.greenDark,
              fontSize: 13,
              padding: 16,
              initialIndex: 0,
              controller: _bitSizeController,
            )

          ],
        ));
  }

  Widget allKeys(){
    return BaseContainer(height: 144,child: Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 48,top: 64),
          child: Image.asset("assets/icons/allKeys.png",color: Theme.of(context).scaffoldBackgroundColor),
        ),
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichTextWidget(
                  fontSize: 13,
                  texts: ["Üretilen\n","Anahtarlar"],
                  colors: [colors.greenDark],
                  fontFamilies: ["FontMedium","FontBold"]
              ),
            ],
          ),
        ),
      ],
    ));
  }

  Widget generateKey(){
    return const BaseContainer(height: 144,child: SizedBox());
  }

  Widget encryptFile(){
    return BaseContainer(
        height: 44,
        child: Row(
          children: [
          BaseContainer(
              color: colors.greenDark,
              radius: 50,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Center(
                  child: RichTextWidget(
                  texts: ["Dosya ","Şifrele"],
                  fontSize: 14,
                  colors: [colors.white],
                  fontFamilies: ["FontMedium","FontBold"]),
                ),
              )),
            const Expanded(child: Center(child: RegularText(texts: "Dosya seçmek için dokunun",size: 13,)))

        ],));
  }

}