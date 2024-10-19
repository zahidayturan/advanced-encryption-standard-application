import 'package:flutter/material.dart';

class CustomDropdownMenu extends StatefulWidget {
  final List<String> list;
  final TextEditingController controller;
  final Color dropdownColor;
  final Color textColor;
  final double padding;
  final double fontSize;
  final ValueChanged<String>? onChanged;
  final int initialIndex;

  const CustomDropdownMenu({
    super.key,
    required this.list,
    required this.controller,
    required this.dropdownColor,
    required this.textColor,
    required this.padding,
    required this.fontSize,
    this.onChanged,
    required this.initialIndex,
  });

  @override
  State<CustomDropdownMenu> createState() => _CustomDropdownMenuState();
}

class _CustomDropdownMenuState extends State<CustomDropdownMenu> {
  @override
  void initState() {
    super.initState();
    widget.controller.text = widget.list[widget.initialIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 17 + (widget.padding / 2),
      padding: EdgeInsets.symmetric(horizontal: widget.padding),
      decoration: BoxDecoration(
          color: widget.dropdownColor,
          borderRadius: BorderRadius.all(Radius.circular(50))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: widget.controller.text,
          dropdownColor: widget.dropdownColor,
          iconEnabledColor: widget.textColor,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          menuMaxHeight: 180,
          items: widget.list.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value,
                  style: TextStyle(
                      fontSize: widget.fontSize,
                      color: widget.textColor)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              widget.controller.text = value!;
              if (widget.onChanged != null) {
                widget.onChanged!(value);
              }
            });
          },
        ),
      ),
    );
  }
}