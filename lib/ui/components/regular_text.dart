import 'package:flutter/material.dart';

class RegularText extends StatelessWidget {
  final String texts;
  final Color? color;
  final double? size;
  final String? family;
  final int? maxLines;
  final FontStyle? style;

  const RegularText({
    required this.texts,
    this.color,
    this.size,
    this.family,
    this.maxLines,
    this.style,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      texts,
      style: TextStyle(
        color: color,
        fontFamily: family,
        fontStyle: style,
        fontSize: size,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: maxLines,
    );
  }
}
