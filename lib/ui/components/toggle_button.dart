import 'package:aes/core/constants/colors.dart';
import 'package:flutter/material.dart';

class ToggleButton extends StatefulWidget {
  final int buttonCount;
  final List<String> buttonNames;
  final ValueChanged<int> onChanged;
  final int initValue;

  const ToggleButton({
    super.key,
    required this.buttonCount,
    required this.buttonNames,
    required this.onChanged,
    this.initValue = 0
  });

  @override
  State<ToggleButton> createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  AppColors colors = AppColors();
  int currentButton = 0;

  @override
  void initState() {
    super.initState();
    currentButton = widget.initValue;
  }

  Widget button(String name, int index) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            currentButton = index;
            widget.onChanged(currentButton);
          });
        },
        child: AnimatedContainer(
          height: currentButton == index ? 26 : 34,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          margin: currentButton == index ? const EdgeInsets.all(4) : EdgeInsets.zero,
          decoration: BoxDecoration(
            color: currentButton == index ? colors.blue : Theme.of(context).colorScheme.primaryContainer,
            borderRadius: const BorderRadius.all(Radius.circular(6)),
          ),
          child: Center(
            child: Text(
              name,
              style: TextStyle(
                color: currentButton == index ? colors.white : colors.blue,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 34,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
        ),
        Row(
          children: List.generate(widget.buttonCount, (index) {
            return button(widget.buttonNames[index], index);
          }),
        ),
      ],
    );
  }
}
