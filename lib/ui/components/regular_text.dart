import 'package:flutter/material.dart';

class RegularText extends StatelessWidget {
  final String texts;
  final Color? color;
  final double? size;
  final String? family;
  final int? maxLines;
  final FontStyle? style;
  final FontWeight? weight;

  const RegularText({
    required this.texts,
    this.color,
    this.size,
    this.family,
    this.maxLines,
    this.style,
    this.weight,
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
        fontWeight: weight
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: maxLines,
    );
  }
}
