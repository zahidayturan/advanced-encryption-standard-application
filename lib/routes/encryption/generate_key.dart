import 'package:aes/routes/encryption/components/e_page_app_bar.dart';
import 'package:aes/ui/components/regular_text.dart';
import 'package:flutter/material.dart';

class GenerateKey extends StatefulWidget {
  final String code;
  const GenerateKey({super.key,required this.code});

  @override
  State<GenerateKey> createState() => _GenerateKeyState();
}

class _GenerateKeyState extends State<GenerateKey> {

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
                    const EPageAppBar(texts: "Anahtar Üretimi",),
                    RegularText(texts: widget.code)
                  ],
                )
            ),
          ),
        ),
      ),
    );
  }

}
