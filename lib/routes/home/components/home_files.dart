import 'package:aes/core/constants/colors.dart';
import 'package:aes/data/services/operations/file_operations.dart';
import 'package:aes/routes/encryption/all_files_page.dart';
import 'package:aes/ui/components/base_container.dart';
import 'package:aes/ui/components/regular_text.dart';
import 'package:aes/ui/components/rich_text.dart';
import 'package:aes/ui/components/shimmer_box.dart';
import 'package:flutter/material.dart';

class HomeFiles extends StatefulWidget {
  const HomeFiles({super.key});

  @override
  State<HomeFiles> createState() => _HomeFilesState();
}

class _HomeFilesState extends State<HomeFiles> {

  AppColors colors = AppColors();
  final fileOperations = FileOperations();

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
        FutureBuilder<List<int>>(
          future: fileOperations.getFileCountForInfo(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return bodyLoading();
              }
              return Column(
                children: [
                  ownedFiles(snapshot.data![0]),
                  const SizedBox(height: 12,),
                  inComingFiles(snapshot.data![1]),
                ],
              );
            },)
      ],
    );
  }

  Widget ownedFiles(int ownedFilesCount){
    return BaseContainer(
        height: 84,
        padding: 0,
        child: Stack(
          children: [
            Positioned(
              left: 14,
              bottom: 0,
              child: Image.asset("assets/icons/ownedFiles.png",height: 72,color: Theme.of(context).scaffoldBackgroundColor),
            ),
            onTapWidget(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AllFilesPage(fileType: "owned",)),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichTextWidget(
                              fontSize: 15,
                              texts: const ["Yüklenen ","Dosyalar"],
                              colors: [Theme.of(context).colorScheme.inversePrimary],
                              fontFamilies: const ["FontMedium","FontBold"]
                          ),
                          Icon(
                            Icons.file_upload_rounded,
                            size: 22,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ],
                      ),
                      Align(
                          alignment: Alignment.bottomRight,
                          child: RegularText(texts: ownedFilesCount == 0 ? "Yüklenen dosyaları görüntüleyin" : "Yüklenen dosya sayısı $ownedFilesCount",size: 11,align: TextAlign.end,))
                    ],
                  ),
                )
            ),
          ],
        ));
  }

  Widget inComingFiles(int inComingFilesCount){
    return BaseContainer(
        height: 84,
        padding: 0,
        child: Stack(
          children: [
            Positioned(
              right: 14,
              bottom: 0,
              child: Image.asset("assets/icons/inComingFiles.png",height: 72,color: Theme.of(context).scaffoldBackgroundColor),
            ),
            onTapWidget(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AllFilesPage(fileType: "inComing",)),
                  );
                  if (result == 'updated') {
                    setState(() {
                    });
                  }

                },
                child:  Padding(
                  padding: const EdgeInsets.all(10),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.file_download_rounded,
                              size: 22,
                              color: Theme.of(context).colorScheme.inversePrimary,
                            ),
                            RichTextWidget(
                                texts: const ["Gelen ","Dosyalar"],
                                fontSize: 15,
                                align: TextAlign.end,
                                colors: [Theme.of(context).colorScheme.inversePrimary],
                                fontFamilies: const ["FontMedium","FontBold"]),
                          ],
                        ),
                        RegularText(texts: inComingFilesCount == 0 ? "Gelen dosyaları görüntüleyin" : "Gelen dosya sayısı $inComingFilesCount",size: 11,align: TextAlign.end,)
                      ],
                    ),
                  ),
                )
            )
          ],
        ));
  }

  Widget onTapWidget({required void Function()? onTap, required Widget child}) {
    return Material(
      type: MaterialType.transparency,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: child,
      ),
    );
  }

  Widget bodyLoading(){
    return const Column(
      children: [
        ShimmerBox(height: 84),
        SizedBox(height: 12,),
        ShimmerBox(height: 84),
      ],
    );
  }
}