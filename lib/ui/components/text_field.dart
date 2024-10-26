import 'package:flutter/material.dart';

class FullTextField extends StatelessWidget {

  final String fieldName;
  final String hintText;
  final TextAlign? align;
  final TextEditingController? myController;
  final IconData myIcon;
  final Color? prefixIconColor;
  final bool readOnly;


  const FullTextField({
    super.key,
    required this.fieldName,
    required this.hintText,
    this.align,
    this.myController,
    this.prefixIconColor,
    required this.myIcon,
    required this.readOnly
  });


  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: myController,
      maxLength: 64,
      readOnly: readOnly,
      cursorColor: Theme.of(context).colorScheme.secondary,
      style: TextStyle(
        color: Theme.of(context).colorScheme.secondary
      ),

      decoration: InputDecoration(
          labelText: fieldName,
          counterText: "",
          hintText: hintText,
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.secondary
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          prefixIcon: Icon(myIcon, color: prefixIconColor ?? Theme.of(context).colorScheme.tertiary),
          enabledBorder: readOnly ? InputBorder.none : OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          focusedBorder: readOnly ? InputBorder.none : OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary),
          ),
          labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary)),
    );
  }
}