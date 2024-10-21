 import 'package:aes/core/constants/colors.dart';
import 'package:aes/routes/encryption/components/e_page_app_bar.dart';
import 'package:aes/ui/components/base_container.dart';
import 'package:aes/ui/components/rich_text.dart';
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
                  true != false ?
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

  Widget keyContainer(){
    return const BaseContainer(
        child: Column(
          children: [

          ],
        ));
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