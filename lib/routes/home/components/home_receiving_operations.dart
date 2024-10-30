import 'package:aes/core/constants/colors.dart';
import 'package:aes/data/models/key_info.dart';
import 'package:aes/data/services/operations/key_operations.dart';
import 'package:aes/routes/encryption/qr_reader.dart';
import 'package:aes/ui/components/base_container.dart';
import 'package:aes/ui/components/date_format.dart';
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
                  SizedBox(height: 16),
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
            onTap: () async {
              KeyInfo? key = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QRCodeReadPage(type: "return")),
              );
              if (key != null) {
                showQRGenerator(key);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: RegularText(texts: "Bir anahtar bulunamadı", color: colors.grey),
                    backgroundColor: colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
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

  void showQRGenerator(KeyInfo keyInfo) {
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
                const SizedBox(height: 24),
                RegularText(
                  texts: "Anahtar alındı",
                  color: Theme.of(context).colorScheme.secondary,
                  family: "FontBold",
                  size: 16,
                ),
                const SizedBox(height: 4),
                RegularText(
                  texts: keyInfo.name != "" ? keyInfo.name : "İsimsiz Anahtar",
                  maxLines: 3,
                  size: 12,
                  align: TextAlign.center,
                ),
                const SizedBox(height: 4),
                RegularText(
                  texts: keyInfo.key,
                  size: 9,
                  align: TextAlign.center,
                ),
                const SizedBox(height: 4),
                RegularText(
                  texts: "AES-${keyInfo.bitLength}",
                  size: 9,
                  align: TextAlign.center,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                    onPressed: () async {
                      LoadingDialog.showLoading(context,message: "Anahtar kaydediliyor");
                      await keyOperations.insertKeyInfo(keyInfo).then((value) {
                        LoadingDialog.hideLoading(context);
                        Navigator.of(context).pop();
                        setState(() {

                        });
                      });

                }, child: RegularText(texts: "Anahtarı kaydet ve çık",color: colors.grey,)),
                const SizedBox(height: 8),
                ElevatedButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: keyInfo.key));
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: RegularText(texts: 'Anahtar panoya kopyalandı', color: colors.grey),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: colors.green,
                      ));

                    }, child: RegularText(texts: "Anahtarı kopyala ve çık",color: colors.grey,)),
              ],
            ),
          ),
        );
      },
    );
  }

}