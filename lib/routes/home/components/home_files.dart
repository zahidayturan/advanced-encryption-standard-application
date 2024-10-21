import 'package:aes/core/constants/colors.dart';
import 'package:aes/ui/components/base_container.dart';
import 'package:aes/ui/components/regular_text.dart';
import 'package:aes/ui/components/rich_text.dart';
import 'package:aes/ui/components/toggle_button.dart';
import 'package:flutter/material.dart';

class HomeFiles extends StatefulWidget {
  const HomeFiles({super.key});

  @override
  State<HomeFiles> createState() => _HomeFilesState();
}

class _HomeFilesState extends State<HomeFiles> {

  AppColors colors = AppColors();

  @override
  Widget build(BuildContext context) {
    return  Stack(
      children: [
        Positioned(
          left: -54,
          top: 42,
          child: RotationTransition(
            turns: const AlwaysStoppedAnimation(30 / 360),
            child: Container(
              height: 200,
              width: 90,
              decoration: BoxDecoration(
                  color: colors.blue,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RegularText(texts: "Dosya İşlemleri",size: 15,color: colors.blue,style: FontStyle.italic,weight: FontWeight.w600,),
                  InkWell(
                      onTap: (){

                      },
                      child: BaseContainer(
                          padding: 2, color: colors.blue, radius: 50,
                          child: Icon(Icons.question_mark_sharp,size: 14,color: colors.grey)))
                ],
              ),
              const SizedBox(height: 12,),
              fileToggle(),
              const SizedBox(height: 12,),
              Row(children: [
                swapButton(),
                const SizedBox(width: 12,),
                Expanded(child: searchBar())
              ],),
              const SizedBox(height: 12,),
              files()
            ],
          ),
        ),
      ],
    );
  }


  Widget fileToggle(){
    return ToggleButton(
        buttonCount: 2,
        initValue: 0,
        buttonNames: const ["Yüklenilen Dosyalar","Gelen Dosyalar"],
        onChanged: (value) {

        },);
  }

  Widget files(){
    return BaseContainer(
        height: 96,
        padding: 10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              RegularText(texts: "dosya_adi",size: 13,family: "FontBold"),
              RegularText(texts: "yuklenme_tarihi",size: 12,align: TextAlign.end,)
            ]),
            const RegularText(texts: "dosya_boyutu",size: 11),
            const RegularText(texts: "dosya_turu",size: 11),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                RichTextWidget(
                    texts: const ["bit_sayisi ","bit anahtar ile şifrelendi"],
                    colors: [colors.black],
                    fontSize: 12,
                    fontFamilies: const ["FontBold","FontMedium"]),
                BaseContainer(
                    padding: 2,
                    color: Theme.of(context).scaffoldBackgroundColor,
                    radius: 50,
                    child: Icon(Icons.more_horiz_rounded,size: 20,color: colors.blue))
              ],
            )
          ],
        ),
    );
  }

  Widget swapButton(){
    return BaseContainer(
      height: 32,
      padding: 8,
      radius: 50,
      child: Image.asset("assets/icons/sort.png",color: colors.blue,height: 22),
    );
  }

  Widget searchBar(){
    return BaseContainer(
      height: 32,
      padding: 0,
      radius: 50,
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: TextField(
          onTap: () {},
          style: TextStyle(
              fontSize: 12,
              color: colors.black
          ),
          readOnly: false,
          decoration: InputDecoration(
              hintText: "Yüklenilen dosyalar içerisinde arayın",
              hintMaxLines: 1,
              isDense: true,
              hintStyle: TextStyle(
                  fontSize: 12,
                  color: colors.black
              ),
              border: InputBorder.none,
              suffixIcon: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {

                },
                icon: Image.asset("assets/icons/search.png",height: 22,color: colors.blue,
              )
          ),
        ),
    ),
      )
    );
  }

}