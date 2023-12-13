import 'package:flutter/cupertino.dart';
import 'cdk_theme.dart';

// Copyright © 2023 Albert Palacios. All Rights Reserved.
// Licensed under the BSD 3-clause license, see LICENSE file for details.

class CDKDialogOuterShadowPainter extends CustomPainter {
  final Color colorBackground;
  final Path pathContour;
  final bool isLightTheme;

  CDKDialogOuterShadowPainter(
      {required this.colorBackground,
      required this.pathContour,
      required this.isLightTheme});

  @override
  void paint(Canvas canvas, Size size) {
    // Pinta l'ombra
    _drawShadow(canvas, pathContour, size);

    // Pinta el fons
    final Paint paintBack = Paint()
      ..color = colorBackground
      ..style = PaintingStyle.fill;

    canvas.drawPath(pathContour, paintBack);

    // Pinta el contorn
    final paintLine = Paint()
      ..strokeWidth = 0.5
      ..color = isLightTheme ? CDKTheme.grey200 : CDKTheme.grey500
      ..style = PaintingStyle.stroke;

    canvas.drawPath(pathContour, paintLine);
  }

  void _drawShadow(Canvas canvas, Path path, Size size) {
    canvas.save();
    // Crear un path que cobreixi tot el canvas
    final outerPath = Path()
      ..addRect(Rect.fromLTRB(0, 0, size.width, size.height));

    // Combina els paths per crear una àrea de clipping que exclogui el contorn
    final clipPath = Path.combine(PathOperation.difference, outerPath, path);
    canvas.clipPath(clipPath);

    // Defineix i dibuixa l'ombra
    Color shadowColor =
        isLightTheme ? CDKTheme.black.withOpacity(0.5) : CDKTheme.black;
    final shadowPaint = Paint()
      ..color = shadowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawShadow(path, shadowPaint.color, 4.0, true);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CDKDialogOuterShadowPainter oldDelegate) {
    return colorBackground != oldDelegate.colorBackground ||
        pathContour != oldDelegate.pathContour ||
        isLightTheme != oldDelegate.isLightTheme;
  }

  static Path createContourPath(Rect rect) {
    const Radius radius = Radius.circular(8);
    final path = Path();

    path.moveTo(rect.left + radius.x, rect.top);

    path.lineTo(rect.right - radius.x, rect.top);
    path.arcToPoint(Offset(rect.right, rect.top + radius.y),
        radius: radius, clockwise: true);

    path.lineTo(rect.right, rect.bottom - radius.y);
    path.arcToPoint(Offset(rect.right - radius.x, rect.bottom),
        radius: radius, clockwise: true);
    path.lineTo(rect.left + radius.x, rect.bottom);
    path.arcToPoint(Offset(rect.left, rect.bottom - radius.y),
        radius: radius, clockwise: true);
    path.lineTo(rect.left, rect.top + radius.y);
    path.arcToPoint(Offset(rect.left + radius.x, rect.top),
        radius: radius, clockwise: true);

    path.close();

    return path;
  }

  static Path createContourPathArrowed(
      Rect rect, double arrowDiffX, bool arrowAtTop) {
    const Radius radius = Radius.circular(8);
    final path = Path();

    path.moveTo(rect.left + radius.x, rect.top);

    // Flexta superior
    if (arrowAtTop) {
      Offset arrowMidPoint = Offset(rect.center.dx + arrowDiffX, rect.top - 8);
      Offset arrowLeft = Offset(arrowMidPoint.dx - 8, rect.top);
      Offset arrowRight = Offset(arrowMidPoint.dx + 8, rect.top);
      path.lineTo(arrowLeft.dx, arrowLeft.dy);
      path.lineTo(arrowMidPoint.dx, arrowMidPoint.dy);
      path.lineTo(arrowRight.dx, arrowRight.dy);
    }

    path.lineTo(rect.right - radius.x, rect.top);
    path.arcToPoint(Offset(rect.right, rect.top + radius.y),
        radius: radius, clockwise: true);

    path.lineTo(rect.right, rect.bottom - radius.y);
    path.arcToPoint(Offset(rect.right - radius.x, rect.bottom),
        radius: radius, clockwise: true);

    // Flexta inferior
    if (!arrowAtTop) {
      Offset arrowMidPoint =
          Offset(rect.center.dx + arrowDiffX, rect.bottom + 8);
      Offset arrowLeft = Offset(arrowMidPoint.dx - 8, rect.bottom);
      Offset arrowRight = Offset(arrowMidPoint.dx + 8, rect.bottom);
      path.lineTo(arrowRight.dx, arrowRight.dy);

      path.lineTo(arrowMidPoint.dx, arrowMidPoint.dy);
      path.lineTo(arrowLeft.dx, arrowLeft.dy);
    }

    path.lineTo(rect.left + radius.x, rect.bottom);
    path.arcToPoint(Offset(rect.left, rect.bottom - radius.y),
        radius: radius, clockwise: true);
    path.lineTo(rect.left, rect.top + radius.y);
    path.arcToPoint(Offset(rect.left + radius.x, rect.top),
        radius: radius, clockwise: true);

    path.close();

    return path;
  }
}
