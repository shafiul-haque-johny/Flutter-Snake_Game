import 'dart:async';
import 'package:flutter/material.dart';
import 'package:snake_game/color_code.dart';
import 'package:snake_game/control_panel.dart';
import 'dart:math';
import 'package:snake_game/piece.dart';
import 'direction.dart';
import 'dart:math' as math;

class SnakeGame extends StatefulWidget {
  const SnakeGame({Key? key}) : super(key: key);

  @override
  State<SnakeGame> createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  var upperBoundX, upperBoundY, lowerBoundX, lowerBoundY;
  late double screenWidth, screenHeight;
  int step = 30;
  int length = 5;
  Offset? foodPosition;
  int score = 0;
  double speed = 0.25;
  late Piece food;

  List<Offset> positions = [];
  Direction direction = Direction.right;
  Timer? timer;

  void changeSpeed() {
    if (timer != null && timer!.isActive) {
      timer!.cancel();
    }
    timer = Timer.periodic(Duration(milliseconds: 200 ~/ speed), (timer) {
      setState(() {});
    });
  }

  Widget getControls() {
    return ControlPanel(onTrapped: (Direction newDirection) {
      direction = newDirection;
    });
  }

  Direction getRandomDirection() {
    int val = Random().nextInt(4);
    direction = Direction.values[val];
    return direction;
  }

  void reStart() {
    length = 5;
    score = 0;
    speed = 0.50;
    positions = [];
    direction = getRandomDirection();
    changeSpeed();
  }

  @override
  void initState() {
    super.initState();
    reStart();
  }

  int getNearestTens(int num) {
    int output;
    output = (num ~/ step) * step; //~ return complete value
    if (output == 0) {
      output += step;
    }
    return output;
  }

  Offset getRandomPosition() {
    Offset position;
    int posX = Random().nextInt(upperBoundX + lowerBoundX);
    int posY = Random().nextInt(upperBoundY + lowerBoundY);
    position = Offset(
        getNearestTens(posX).toDouble(), getNearestTens(posY).toDouble());
    return position;
  }

  void draw() async {
    if (positions.isEmpty) {
      positions.add(getRandomPosition());
    }
    while (length > positions.length) {
      positions.add(positions[positions.length - 1]);
    }
    for (var i = positions.length - 1; i > 0; i--) {
      positions[i] = positions[i - 1]; //4<--3, 3<--2, 2<--1, 1<--0
    }

    positions[0] = (await getNextPosition(positions[0]));
  }

  bool detectCollision(Offset position) {
    if (position.dx >= upperBoundX && direction == Direction.right) {
      return true;
    } else if (position.dx <= lowerBoundX && direction == Direction.left) {
      return true;
    } else if (position.dy >= upperBoundY && direction == Direction.down) {
      return true;
    } else if (position.dy <= lowerBoundY && direction == Direction.up) {
      return true;
    }

    return false;
  }

  void showGameOverDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.red,
          shape: const RoundedRectangleBorder(
              side: BorderSide(color: Colors.blue, width: 3.0),
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: const Text(
            "Game Over!",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Your game is over but you played well. Your score is " +
                score.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                reStart();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.blue[400]),
              ),
              child: const Text(
                "Restart",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<Offset> getNextPosition(Offset position) async {
    late Offset nextPosition;
    if (direction == Direction.right) {
      nextPosition = Offset(position.dx + step, position.dy);
    } else if (direction == Direction.left) {
      nextPosition = Offset(position.dx - step, position.dy);
    } else if (direction == Direction.up) {
      nextPosition = Offset(position.dx, position.dy - step);
    } else if (direction == Direction.down) {
      nextPosition = Offset(position.dx, position.dy + step);
    }

    if (detectCollision(position) == true) {
      if (timer != null && timer!.isActive) {
        timer?.cancel();
      }
      await Future.delayed(
          Duration(milliseconds: 200), () => showGameOverDialog());
      return position;
    }
    return nextPosition;
  }

  void drawFood() {
    foodPosition ??= getRandomPosition();

    if (foodPosition == positions[0]) {
      length++;
      score = score + 5;
      speed = speed + 0.25;
      foodPosition = getRandomPosition();
    }

    food = Piece(
      posX: foodPosition!.dx.toInt(),
      posY: foodPosition!.dy.toInt(),
      size: step,
      // Random Color
      color: Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
          .withOpacity(1.0),
      isAnimated: true,
    );
  }

  List<Piece> getPieces() {
    final pieces = <Piece>[];
    draw();
    drawFood();
    for (var i = 0; i < length; ++i) {
      if (i >= positions.length) {
        continue;
      }
      pieces.add(Piece(
        color: Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
            .withOpacity(1.0),
        //color: i.isEven ? Colors.redAccent : Colors.green,
        size: step,
        posX: positions[i].dx.toInt(),
        posY: positions[i].dy.toInt(),
        isAnimated: false,
      ));
    }
    return pieces;
  }

  Widget getScore() {
    return Positioned(
        top: 15.0,
        right: 20.0,
        child: Text(
          "Score :" + score.toString(),
          style: const TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
        ));
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    lowerBoundX = step;
    lowerBoundY = step;
    upperBoundY = getNearestTens(screenHeight.toInt() - step); //906
    upperBoundX = getNearestTens(screenWidth.toInt() - step); //408

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [gradient4, gradient5, gradient6],
          ),
        ),
        child: Stack(
          children: [
            Stack(
              children: getPieces(),
            ),
            getControls(),
            food,
            getScore(),
          ],
        ),
      ),
    );
  }
}
