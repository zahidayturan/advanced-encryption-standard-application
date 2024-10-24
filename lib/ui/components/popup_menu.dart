import 'package:flutter/material.dart';

void showPopupMenu(
    Offset offset,
    Color backColor,
    double marginRight,
    List<PopupMenuEntry<int>> items,
    Future<void> Function(int?) func,
    BuildContext context
    ) {
  double left = offset.dx;
  double top = offset.dy;
  showMenu<int>(
    context: context,
    color: backColor,
    position: RelativeRect.fromLTRB(left, top + 8, marginRight, 0),
    items: items,
    elevation: 4.0,
    shape: RoundedRectangleBorder(
      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
      side: BorderSide(color: Theme.of(context).primaryColor, width: 1),
    ),
  ).then((value) {
    if (value != null) {
      func(value);
    }
  });
}