import 'package:aes/core/constants/colors.dart';
import 'package:aes/data/models/file_info.dart';
import 'package:aes/data/services/operations/file_operations.dart';
import 'package:aes/ui/components/base_container.dart';
import 'package:aes/ui/components/regular_text.dart';
import 'package:aes/ui/components/rich_text.dart';
import 'package:aes/ui/components/shimmer_box.dart';
import 'package:aes/ui/components/toggle_button.dart';
import 'package:flutter/material.dart';

class HomeFiles extends StatefulWidget {
  const HomeFiles({super.key});

  @override
  State<HomeFiles> createState() => _HomeFilesState();
}

class _HomeFilesState extends State<HomeFiles> {

  AppColors colors = AppColors();
  final fileOperations = FileOperations();
  int activeButton = 0;

  @override
  Widget build(BuildContext context) {
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RegularText(texts: "Dosya İşlemleri",size: 15,color: Theme.of(context).colorScheme.onTertiary,style: FontStyle.italic,weight: FontWeight.w600,),
            InkWell(
                onTap: (){

                },
                child: BaseContainer(
                    padding: 2, color: Theme.of(context).colorScheme.onTertiary, radius: 50,
                    child: Icon(Icons.question_mark_sharp,size: 14,color: colors.grey)))
          ],
        ),
        const SizedBox(height: 12,),
        fileToggle(),
        const SizedBox(height: 12,),
        FutureBuilder<List<FileInfo>?>(
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
    );
  }


  Widget fileToggle(){
    return ToggleButton(
        buttonCount: 2,
        initValue: activeButton,
        buttonNames: const ["Yüklenilen Dosyalar","Gelen Dosyalar"],
        onChanged: (value) {
          setState(() {
            activeButton = value;
          });
        },);
  }

  Widget files(List<FileInfo> list){
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
                height: 96,
                padding: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RegularText(texts: item.name,size: 13,family: "FontBold"),
                          RegularText(texts: item.creationTime,size: 12,align: TextAlign.end,)
                        ]),
                    const RegularText(texts: "dosya_boyutu",size: 11),
                    RegularText(texts: item.type,size: 11),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        RichTextWidget(
                            texts: ["${item.keyId} ","bit anahtar ile şifrelendi"],
                            colors: [Theme.of(context).colorScheme.secondary],
                            fontSize: 12,
                            fontFamilies: const ["FontBold","FontMedium"]),
                        BaseContainer(
                            padding: 2,
                            color: Theme.of(context).scaffoldBackgroundColor,
                            radius: 50,
                            child: Icon(Icons.more_horiz_rounded,size: 20,color: Theme.of(context).colorScheme.onTertiary))
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
              hintText: "Yüklenilen dosyalar içerisinde arayın",
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