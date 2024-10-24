import 'package:aes/core/constants/colors.dart';
import 'package:aes/data/models/key_info.dart';
import 'package:aes/data/services/operations/key_operations.dart';
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
  KeyOperations keyOperations = KeyOperations();

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
                  const EPageAppBar(texts: "Üretilen Anahtarlar"),
                  FutureBuilder<List<KeyInfo>?>(
                    future: keyOperations.getAllKeyInfo(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return loadingContainer();
                      }
                      if (snapshot.hasError) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 18),
                            child: RegularText(texts: "Hata ile karşışaşıldı",size: 15),
                          ),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 18),
                            child: RegularText(texts: "Anahtar bulunamadı",size: 15),
                          ),
                        );
                      }
                      return keyContainer(snapshot.data!);
                    },
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget keyContainer(List<KeyInfo> keys) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: RegularText(texts: "${keys.length} anahtar bulundu",size: 12,),
          ),
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: keys.length,
          itemBuilder: (context, index) {
            var item = keys[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
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
                          child: Icon(
                            Icons.more_vert_rounded,
                            size: 20,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    RegularText(
                      texts: "AES-${item.bitLength} bit",
                    ),
                    RegularText(
                      texts: item.generateType,
                    ),
                    Text(
                      item.key,
                      style: TextStyle(
                        fontSize: 9,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ],
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
