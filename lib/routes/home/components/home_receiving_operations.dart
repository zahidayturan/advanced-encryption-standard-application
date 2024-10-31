import 'package:aes/core/constants/colors.dart';
import 'package:aes/data/models/file_info.dart';
import 'package:aes/data/models/key_info.dart';
import 'package:aes/data/services/operations/file_operations.dart';
import 'package:aes/data/services/operations/key_operations.dart';
import 'package:aes/routes/encryption/qr_reader.dart';
import 'package:aes/ui/components/base_container.dart';
import 'package:aes/ui/components/loading.dart';
import 'package:aes/ui/components/regular_text.dart';
import 'package:aes/ui/components/rich_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReceivingOperations extends StatefulWidget {
  const ReceivingOperations({super.key});

  @override
  State<ReceivingOperations> createState() => _ReceivingOperationsState();
}

class _ReceivingOperationsState extends State<ReceivingOperations> {

  AppColors colors = AppColors();
  KeyOperations keyOperations = KeyOperations();
  FileOperations fileOperations = FileOperations();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RegularText(texts: "Alma İşlemleri",size: 15,color: Theme.of(context).colorScheme.secondary,style: FontStyle.italic,weight: FontWeight.w600,),
            InkWell(
                onTap: (){

                },
                child: BaseContainer(
                    padding: 2, color: Theme.of(context).colorScheme.secondary, radius: 50,
                    child: Icon(Icons.question_mark_sharp,size: 14,color:Theme.of(context).primaryColor)))
          ],
        ),
        const SizedBox(height: 12,),
        Row(children: [
          Expanded(
              flex: 1,
              child: getFile()),
          const SizedBox(width: 12,),
          Expanded(
              flex: 1,
              child: getKey())
        ],),
      ],
    );
  }

  Widget getFile(){
    return BaseContainer(
        padding: 0,
        child: onTapWidget(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QRCodeReadPage(type: "returnFile")),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichTextWidget(
                      fontSize: 15,
                      texts: const ["Dosya\n","Al"],
                      colors: [Theme.of(context).colorScheme.secondary],
                      fontFamilies: const ["FontMedium","FontBold"]
                  ),
                  const SizedBox(height: 16),
                  Align(
                      alignment: Alignment.bottomRight,
                      child: Icon(
                        Icons.file_open,
                        size: 22,
                        color: Theme.of(context).colorScheme.secondary,
                      ),)
                ],
              ),
            )
        ));
  }

  Widget getKey(){
    return BaseContainer(
        padding: 0,
        child: onTapWidget(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QRCodeReadPage(type: "returnKey")),
              );
            },
            child:  Padding(
              padding: const EdgeInsets.all(10),
              child: Align(
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichTextWidget(
                        texts: const ["Anahtar\n","Al"],
                        fontSize: 15,
                        align: TextAlign.end,
                        colors: [Theme.of(context).colorScheme.secondary],
                        fontFamilies: const ["FontMedium","FontBold"]),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Icon(
                        Icons.key_outlined,
                        size: 22,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
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

}