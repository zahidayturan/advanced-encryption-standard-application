import 'package:aes/core/constants/colors.dart';
import 'package:aes/ui/components/regular_text.dart';
import 'package:flutter/cupertino.dart';


AppColors colors = AppColors();

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key});
  @override
  Widget build(BuildContext context){
    return Row(
      children: [
        RegularText(texts: "AES",size: 17,color: colors.orange,family: "FontBold"),
        const SizedBox(width: 4,),
        RegularText(texts: "Gelişmiş Şifreleme Standardı",size: 12,color: colors.orange,style: FontStyle.italic),
        const Spacer(),
        SizedBox(
            height: 26,
            child: Image.asset("assets/icons/settings.png",color: colors.orange,))
      ],
    );
  }
}