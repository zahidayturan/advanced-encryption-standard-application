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
    return  Stack(
      children: [
        Positioned(
          right: -54,
          top: 44,
          child: RotationTransition(
            turns: const AlwaysStoppedAnimation(30 / 360),
            child: Container(
              height: 200,
              width: 110,
              decoration: BoxDecoration(
                color: colors.greenDark,
                borderRadius: const BorderRadius.all(Radius.circular(8))
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
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
          ),
        )
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
              list: const ["128 bit","192 bit","256 bit"],
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
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichTextWidget(
                  fontSize: 14,
                  texts: const ["Üretilen\n","Anahtarlar"],
                  colors: [colors.greenDark],
                  fontFamilies: const ["FontMedium","FontBold"]
              ),
              const Align(
                  alignment: Alignment.bottomRight,
                  child: RegularText(texts: "Üretilmiş\nanahtar\nyok",size: 11,align: TextAlign.end,))
            ],
          ),
        ),
      ],
    ));
  }

  Widget generateKey(){
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
            Padding(
              padding: const EdgeInsets.all(10),
              child: Align(
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BaseContainer(
                        color: colors.greenDark,
                        radius: 50,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: RichTextWidget(
                              texts: const ["Anahtar ","Üret"],
                              fontSize: 14,
                              colors: [colors.white],
                              fontFamilies: const ["FontMedium","FontBold"]),
                        )),
                    const RegularText(texts: "Aktif anahtar\nyok",size: 11,align: TextAlign.end,)
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  Widget encryptFile(){
    return BaseContainer(
        padding: 0,
        child: Stack(
          children: [
            Positioned(
              right: 54,
              bottom: 4,
              child: RotationTransition(
                  turns: const AlwaysStoppedAnimation(30 / 360),
                  child: Image.asset("assets/icons/addFile.png",height: 90,color: Theme.of(context).scaffoldBackgroundColor)),
            ),
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () {

                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          BaseContainer(
                              color: colors.greenDark,
                              radius: 50,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: RichTextWidget(
                                    texts: const ["Dosya ","Şifrele"],
                                    fontSize: 14,
                                    colors: [colors.white],
                                    fontFamilies: const ["FontMedium","FontBold"]),
                              )),
                          Icon(Icons.add_circle_outline_rounded,size: 24,color: colors.greenDark,)
                        ],
                      ),
                      const SizedBox(height: 12,),
                      const Center(child: RegularText(texts: "Dosya seçmek için dokunun",size: 13,)),
                      const SizedBox(height: 12,),
                    ],),
                ),
              ),
            )
          ],
        ));
  }

}