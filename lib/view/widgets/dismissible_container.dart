import 'package:flutter/material.dart';

class DismissibleContainer extends StatefulWidget {
  final Offset targetPoint;
  final VoidCallback onDismiss;

  DismissibleContainer({required this.targetPoint, required this.onDismiss});

  @override
  _DismissibleContainerState createState() => _DismissibleContainerState();
}

class _DismissibleContainerState extends State<DismissibleContainer> {
  Offset position = Offset(0, 0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (DragUpdateDetails details) {
        setState(() {
          position += details.delta;
        });
      },
      onPanEnd: (DragEndDetails details) {
        if (position.dx >= widget.targetPoint.dx &&
            position.dy >= widget.targetPoint.dy) {
          widget.onDismiss();
        } else {
          setState(() {
            position = Offset(0, 0);
          });
        }
      },
      child: Align(
        alignment: Alignment.topLeft,
        child: Transform.translate(
          offset: position,
          child: Draggable(
            child: Container(
              width: 100,
              height: 100,
              color: Colors.blue,
              child: Center(
                child: Text(
                  'Drag me!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            feedback: Container(
              width: 100,
              height: 100,
              color: Colors.blue.withOpacity(0.7),
              child: Center(
                child: Text(
                  'Dragging...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            childWhenDragging: Container(),
          ),
        ),
      ),
    );
  }
}
