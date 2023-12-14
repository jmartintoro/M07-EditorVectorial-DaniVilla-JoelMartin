import 'package:editor_vectorial_dj/cositas/cdk.dart';
import 'package:flutter/cupertino.dart';

class Shape {
  Offset position = const Offset(0, 0);
  Size scale = const Size(1, 1);
  Color strokeColor = CDKTheme.black;
  double strokeWeight = 1;
  Offset initialPosition = Offset(0, 0);
  double rotation = 0;
  List<Offset> points = [];

  Shape();

  void setStrokeWeight(double newWeight) {
    strokeWeight = newWeight;
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
    points.add(Offset(point.dx, point.dy));
  }

  void addRelativePoint(Offset point) {
    points.add(Offset(point.dx - position.dx, point.dy - position.dy));
  }
}
