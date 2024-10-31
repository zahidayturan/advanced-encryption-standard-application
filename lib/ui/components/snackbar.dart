import 'package:aes/ui/components/regular_text.dart';
import 'package:flutter/material.dart';

void showSnackbar(String message, Color backgroundColor,BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: RegularText(texts: message, color: const Color(0xFFF5F5F5)),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
    ),
  );
}