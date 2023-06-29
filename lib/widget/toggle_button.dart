import 'package:flutter/material.dart';

class ToggleButton extends StatelessWidget {
  final bool active;
  final String text;
  final void Function()? onPressed;

  const ToggleButton({super.key, required this.active, required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    Color backgroundColor = active ? Theme.of(context).primaryColor : Colors.black12;
    Color foregroundColor = active ? Colors.white : Colors.black87;
    return TextButton(
      style: TextButton.styleFrom(backgroundColor: backgroundColor, foregroundColor: foregroundColor),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
