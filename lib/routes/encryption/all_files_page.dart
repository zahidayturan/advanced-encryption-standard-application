import 'package:aes/core/constants/colors.dart';
import 'package:aes/data/models/dto/key_file.dart';
import 'package:aes/data/services/operations/file_operations.dart';
import 'package:aes/routes/encryption/components/e_page_app_bar.dart';
import 'package:aes/ui/components/base_container.dart';
import 'package:aes/ui/components/regular_text.dart';
import 'package:aes/ui/components/rich_text.dart';
import 'package:aes/ui/components/shimmer_box.dart';
import 'package:flutter/material.dart';

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
