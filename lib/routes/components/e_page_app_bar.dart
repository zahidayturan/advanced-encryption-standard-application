import 'package:aes/core/constants/colors.dart';
import 'package:aes/ui/components/regular_text.dart';
import 'package:flutter/material.dart';

AppColors colors = AppColors();

class EPageAppBar extends StatelessWidget {
  final String texts;
  final bool dataChanged;
  const EPageAppBar({super.key, required this.texts, required this.dataChanged});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
            onPressed: () {
              Navigator.pop(context, dataChanged ? 'updated' : '');
        }, icon: Icon(Icons.arrow_back_rounded,color: Theme.of(context).colorScheme.secondary,)),
        RegularText(texts: texts,size: 17,align: TextAlign.end,)
      ],
    );
  }

}