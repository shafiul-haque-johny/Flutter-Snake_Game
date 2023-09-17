import 'package:flutter/material.dart';
import 'control_button.dart';
import 'direction.dart';

class ControlPanel extends StatelessWidget {
  final void Function(Direction direction) onTrapped;
  const ControlPanel({Key? key, required this.onTrapped}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0.0,
      bottom: 50.0,
      child: Row(
        children: [
          Expanded(
              child: Row(
            children: [
              Expanded(child: Container()),
              ControlButton(
                onPressed: () {
                  onTrapped(Direction.left);
                },
                icon: const Icon(Icons.arrow_left),
              ),
            ],
          )),
          Expanded(
              child: Column(
            children: [
              ControlButton(
                onPressed: () {
                  onTrapped(Direction.up);
                },
                icon: const Icon(Icons.arrow_drop_up),
              ),
              const SizedBox(
                height: 70,
              ),
              ControlButton(
                onPressed: () {
                  onTrapped(Direction.down);
                },
                icon: const Icon(Icons.arrow_drop_down),
              ),
            ],
          )),
          Expanded(
            child: Row(
              children: [
                ControlButton(
                  onPressed: () {
                    onTrapped(Direction.right);
                  },
                  icon: const Icon(Icons.arrow_right),
                ),
                //Expanded(child: Container()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
