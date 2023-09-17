import 'package:flutter/material.dart';

import 'color_code.dart';

class ControlButton extends StatelessWidget {
  const ControlButton({Key? key, required this.onPressed, required this.icon})
      : super(key: key);

  final onPressed;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.5,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [gradient1, gradient2, gradient3],
          ),
        ),
        width: 80.0,
        height: 80.0,
        child: FittedBox(
          child: FloatingActionButton(
            backgroundColor: Colors.transparent,
            //backgroundColor: const Color.fromRGBO(9, 236, 236, 1.0),
            elevation: 0.0,
            onPressed: this.onPressed,
            child: this.icon,
          ),
        ),
      ),
    );
  }
}
