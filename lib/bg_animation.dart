import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_application_1/effects.dart';

//initialize background
double dx = 1.0;
double vx = 0.2;
const int imageWidth = 1920;

void parallaxBg(canvas, size, _bgImage) {
  vx = (dx + size.x > imageWidth || dx < 0) ? -vx : vx;
  dx += vx;

  final Paint bgPaint = Paint()..color = const Color.fromRGBO(0, 0, 0, 1);
  Rect srcRect = Offset(dx, 300) & Size(size.x, size.y);
  Rect dstRect = const Offset(0, 0) & Size(size.x, size.y);
  canvas.drawImageRect(_bgImage, srcRect, dstRect, bgPaint);
}

void initBgStarAnimate(starInit, size) {
  for (int i = 0; i < starInit['total']; i++) {
    starInit['stars'].add(Star());
    starInit['stars'][i].init();
    starInit['stars'][i].x = math.Random().nextDouble() * (size.x - 10) + 5;
    starInit['stars'][i].y = math.Random().nextDouble() * (size.y - 10) + 5;
  }
}

//background star position update & rendering
void updateRenderBgStar(canvas, size, starInit, stageNo) {
  dynamic stars = starInit['stars'];
  final double fontSize = math.min(size.x / 2, 400);
  if (stageNo > 0) {
    Effects.drawText(
      canvas,
      size,
      Offset(0.0, size.y * 0.2 + fontSize * 1.1),
      stageNo.toString(),
      fontSize: fontSize,
      fontName: 'Picture Regular',
      color: const Color.fromRGBO(250, 250, 200, 0.25),
      align: TextAlign.center,
    );
  }
  for (int i = 0; i < stars.length; i++) {
    stars[i].x += stars[i].vx;
    stars[i].y += stars[i].vy;

    var ix = stars[i].x;
    var iy = stars[i].y;
    var radius = stars[i].r;
    var colorRgb = stars[i].rgb;

    final maxX = size.x - radius;
    final maxY = size.y - radius;

    if (ix <= radius) stars[i].x = size.x - stars[i].r;
    if (ix > maxX) stars[i].x = radius;
    if (iy <= radius) stars[i].y = size.y - stars[i].r;
    if (iy > maxY) stars[i].y = radius;

    Paint starColor = Paint()
      ..color = Color.fromRGBO(colorRgb[0], colorRgb[1], colorRgb[2], 0.5);
    canvas.drawCircle(Offset(ix, iy), radius, starColor);

    for (int j = i; j < stars.length; j++) {
      var jx = stars[j].x;
      var jy = stars[j].y;
      double distance = math.sqrt(math.pow(ix - jx, 2) + math.pow(iy - jy, 2));
      if (distance < starInit['stsNearDist']) {
        distance = (1 - (distance / starInit['stsNearDist'])) * 0.5;
        Paint starColor = Paint()
          ..strokeWidth = 1
          ..color = Color.fromRGBO(150, 200, 200, distance);
        canvas.drawLine(Offset(ix, iy), Offset(jx, jy), starColor);
      }
    }
  }
}

class Star {
  late double x, y;

  double vx = math.Random().nextDouble() * 0.4 + 0.2;
  double vy = math.Random().nextDouble() * 0.4 + 0.2;
  final double r = 1.5;
  late List<int> rgb;

  void init() {
    vx = math.Random().nextBool() ? vx : -vx;
    vy = math.Random().nextBool() ? vy : -vy;
    rgb = [
      math.Random().nextInt(156) + 100,
      math.Random().nextInt(156) + 100,
      math.Random().nextInt(156) + 100,
    ];
    rgb[math.Random().nextInt(3)] = 0;
  }
  // @override
  // Future<void> onLoad() async {
  //   super.onLoad();
  // }
}
