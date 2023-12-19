import 'package:flutter/cupertino.dart';
import 'package:flutter_cupertino_desktop_kit/cdk_theme.dart';

class Shape {
  Offset position = const Offset(0, 0);
  Size scale = const Size(1, 1);
  Color strokeColor = CDKTheme.black;
  double strokeWidth= 1;
  Offset initialPosition = Offset(0, 0);
  double rotation = 0;
  List<Offset> vertices = [];

  Shape();

  void setStrokeWidth(double newWeight) {
    strokeWidth = newWeight;
  }

  void setStrokeColor(Color newColor) {
    strokeColor = newColor;
  }

  void setInitialPosition(Offset newIniPosition) {
    initialPosition = newIniPosition;
  }

  void setPosition(Offset newPosition) {
    position = newPosition;
  }

  void setScale(Size newScale) {
    scale = newScale;
  }

  void setRotation(double newRotation) {
    rotation = newRotation;
  }

  void addPoint(Offset point) {
    vertices.add(Offset(point.dx, point.dy));
  }

  void addRelativePoint(Offset point) {
    vertices.add(Offset(point.dx - position.dx, point.dy - position.dy));
  }
}
