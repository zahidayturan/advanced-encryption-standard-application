import 'package:flutter/material.dart';

class RichTextWidget extends StatelessWidget {
  final List<String> texts;
  final List<Color> colors;
  final List<String> fontFamilies;
  final double fontSize;
  final TextAlign align;

  RichTextWidget({
    Key? key,
    required this.texts,
    required List<Color> colors,
    required List<String> fontFamilies,
    this.fontSize = 15.0,
    this.align = TextAlign.start,
  })  : colors = (colors.length == 1)
      ? List.generate(texts.length, (index) => colors[0])
      : colors,
        fontFamilies = (fontFamilies.length == 1)
            ? List.generate(texts.length, (index) => fontFamilies[0])
            : fontFamilies,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    assert(texts.length == colors.length &&
        texts.length == fontFamilies.length);

    List<TextSpan> textSpans = [];
    for (int i = 0; i < texts.length; i++) {
      textSpans.add(
        TextSpan(
          text: texts[i],
          style: TextStyle(
            color: colors[i],
            fontFamily: fontFamilies[i],
            fontSize: fontSize,
          ),
        ),
      );
    }

    return RichText(
      textAlign: align,
      text: TextSpan(children: textSpans),
    );
  }
}
