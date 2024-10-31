import 'package:flutter/material.dart';

Widget onTapWidget({required void Function()? onTap, required Widget child}) {
  return Material(
    type: MaterialType.transparency,
    borderRadius: BorderRadius.circular(8),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: child,
    ),
  );
}