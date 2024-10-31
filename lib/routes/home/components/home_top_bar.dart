import 'package:aes/core/constants/colors.dart';
import 'package:aes/routes/other/settings.dart';
import 'package:aes/ui/components/regular_text.dart';
import 'package:flutter/material.dart';


AppColors colors = AppColors();

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key});
  @override
  Widget build(BuildContext context){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RegularText(texts: "AES",size: 22,color: colors.orange,family: "FontBold"),
            const SizedBox(width: 4,),
            RegularText(texts: "Gelişmiş Şifreleme Standardı",size: 11,color: colors.orange),
          ],
        ),
        IconButton(
          constraints: const BoxConstraints(
            maxHeight: 30
          ),
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          },
          alignment: Alignment.centerRight,
          icon: Icon(Icons.settings_rounded,color: colors.orange,),
        )
      ],
    );
  }
}