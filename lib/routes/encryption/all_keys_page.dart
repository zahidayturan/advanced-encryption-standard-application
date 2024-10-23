 import 'package:aes/core/constants/colors.dart';
import 'package:aes/data/models/key_info.dart';
import 'package:aes/routes/encryption/components/e_page_app_bar.dart';
import 'package:aes/ui/components/base_container.dart';
import 'package:aes/ui/components/regular_text.dart';
import 'package:aes/ui/components/shimmer_box.dart';
import 'package:flutter/material.dart';

class AllKeysPage extends StatefulWidget {
const AllKeysPage({super.key});

@override
State<AllKeysPage> createState() => _AllKeysPageState();
}

class _AllKeysPageState extends State<AllKeysPage> {

  AppColors colors = AppColors();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        resizeToAvoidBottomInset: false,
        bottomNavigationBar: null,
        body: Padding(
          padding: const EdgeInsets.only(right: 12,left: 12,top: 6),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Center(
              child: Column(
                children: [
                  const EPageAppBar(texts: "Üretilen Anahtarlar",),
                  true == false ?
                      keyContainer() :
                      loadingContainer()
                ],
              )
            ),
          ),
        ),
      ),
    );
  }

  List<KeyInfo> tempKey =[
    KeyInfo(
        creationTime: "22.10.2024 01:14",
        bitLength: "256",
        generateType: "QR",
        key: "1564654654564564G54564564G5S6D4G56DS4G56DS4G564SD56G4D5S64G56D")
  ];

  Widget keyContainer(){
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: tempKey.length,
      itemBuilder: (context, index) {
        var item = tempKey[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: BaseContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RegularText(
                          texts: item.creationTime,
                        ),
                        BaseContainer(
                            padding: 2,
                            color: Theme.of(context).scaffoldBackgroundColor,
                            radius: 50,
                            child: Icon(Icons.more_vert_rounded,size: 20,color: Theme.of(context).colorScheme.secondary))
                      ],
                  ),
                  RegularText(
                    texts: "AES-${item.bitLength} bit",
                  ),
                  RegularText(
                    texts: item.generateType,
                  ),
                  Text(item.key,style: TextStyle(fontSize: 9,color: Theme.of(context).colorScheme.secondary),)

                ],
              )),
        );
      },
    );
  }

  Widget loadingContainer() {
    return Column(
      children: List.generate(5, (index) => const Padding(
        padding: EdgeInsets.only(top: 12),
        child: ShimmerBox(height: 120),
      )),
    );
  }


}