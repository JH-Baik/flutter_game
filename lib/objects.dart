import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_application_1/effects.dart';

const double imgSize = 256.0;
const Map<dynamic, dynamic> _imgLocation = {
  1: {
    'x': 1.0,
    'y': 1.0,
    'mass': 0.3,
    'rgb': [173, 255, 47]
  },
  2: {
    'x': 257.0,
    'y': 1.0,
    'mass': 0.35,
    'rgb': [127, 255, 212]
  },
  3: {
    'x': 513.0,
    'y': 1.0,
    'mass': 0.4,
    'rgb': [135, 206, 235]
  },
  4: {
    'x': 769.0,
    'y': 1.0,
    'mass': 0.5,
    'rgb': [255, 0, 255]
  },
  5: {
    'x': 1.0,
    'y': 257.0,
    'mass': 0.6,
    'rgb': [255, 165, 0]
  },
  6: {
    'x': 257.0,
    'y': 257.0,
    'mass': 0.7,
    'rgb': [255, 69, 0]
  },
  'vc': {'x': 1.0, 'y': 513.0, 'size': 256.0},
  'sparkSmall': {
    'x': 257.0,
    'y': 513.0,
  },
  'sparkLarge': {
    'x': 513.0,
    'y': 513.0,
  },
  'vcEffect': {
    1: {'x': 1024.0, 'y': 1024.0},
    3: {'x': 769.0, 'y': 513.0},
    4: {'x': 769.0, 'y': 769.0},
    5: {'x': 513.0, 'y': 769.0},
    6: {'x': 257.0, 'y': 769.0},
    2: {'x': 1.0, 'y': 769.0},
  }
};

class Ball {
  double r, range;
  dynamic stage, imgs;

  Ball(this.stage, this.r, this.range, this.imgs);

  bool isEnemy = true;
  double rotate = 0;
  double rotate2 = 0;
  late Map<dynamic, dynamic> image =
      _imgLocation[(math.Random().nextDouble() * range).floor() + 1];

  static const double speedMax = 5.0;
  final double speedMin = 4.0;
  late double speedx =
      math.Random().nextDouble() * (speedMax - speedMin) + speedMin;
  late double speedy =
      math.Random().nextDouble() * (speedMax - speedMin) + speedMin;

  late double x = r + (math.Random().nextDouble() * (stage.x - r * 2));
  late double y = r + (math.Random().nextDouble() * (stage.y - r * 2));
  late double vx = (x > (stage.x / 2)) ? -speedx : speedx;
  late double vy = (y > (stage.y / 2)) ? -speedx : speedx;
  late double mana = r * image['mass'];

  int expStatus = 0;
  double manaReduceSpeed = 1.5;
  Effects effects = Effects();

  draw(canvas, stage) {
    if (x + r >= stage.x) x = stage.x - (r + 1);
    if (x - r <= 0) x = r + 1;
    if (y + r >= stage.y) y = stage.y - (r + 1);
    if (y - r <= 0) y = r + 1;

    x += vx;
    y += vy;
    bounceStage(stage);

    double _rotate = (vx + vy) / 3;

    canvas.save();
    canvas.translate(x, y);
    canvas.rotate((rotate += _rotate) * (math.pi / 180));
    canvas.translate(-x, -y);

    //draw vaccine object
    if (!isEnemy) {
      const int _gap = 6;

      final int _effMax = _imgLocation['vcEffect'].length;
      const int _effMin = 1;
      final int _getEffectNum = (mana / _gap) > _effMax
          ? _effMax
          : math.max((mana / _gap).floor(), _effMin);
      final vcEffect = _imgLocation['vcEffect'][_getEffectNum];

      _canvasDrawImageRect(canvas, vcEffect['x'], vcEffect['y'], r * 1.5, 0.7);
    }

    _canvasDrawImageRect(canvas, image['x'], image['y'], r, 1.0);
    canvas.restore();

    //draw the outer circle of the COVID by amount of mana
    if (isEnemy) {
      final double _angle = math.pi * 2 / (mana / 3).floor();
      rotate2 += 2;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotate2 * (math.pi / 180));
      canvas.translate(-x, -y);

      for (int i = 0; i < mana / 3; i++) {
        final _ix = x + r * 1.3 * math.cos(_angle * i);
        final _iy = y + r * 1.3 * math.sin(_angle * i);
        final _rgb = image['rgb'];
        Paint _paint = Paint()
          ..color = Color.fromRGBO(_rgb[0], _rgb[1], _rgb[2], 0.7)
          ..imageFilter = ui.ImageFilter.blur(sigmaX: .7, sigmaY: .7);
        canvas.drawCircle(Offset(_ix, _iy), 4.0, _paint);
      }

      canvas.restore();
    }

    if (!isEnemy) {
      Paint _paint = Paint() // Paint 클래스는 어떤 식으로 화면을 그릴지 정할 때 쓰임.
        ..color = const ui.Color.fromRGBO(170, 255, 251, 0.7) // 색은 보라색
        ..strokeCap = StrokeCap.round // 선의 끝은 둥글게 함.
        ..strokeWidth = 4.0; // 선의 굵기는 4.0
      final Offset startOffset = Offset(x - r / 2, y - r - 10);
      final Offset endOffset = Offset(x + r / 2 - 5, y - r - 10);
      canvas.drawLine(startOffset, endOffset, _paint);
      final Offset manaEndOffset =
          Offset((x - r / 2) + mana / 0.7 - 5, y - r - 10);
      canvas.drawLine(startOffset, manaEndOffset,
          _paint..color = const ui.Color.fromRGBO(17, 73, 255, 0.694));
    }
  }

  void _canvasDrawImageRect(canvas, imgX, imgY, r, imageOpacity) {
    Paint _paint = Paint()..color = Color.fromRGBO(0, 0, 0, imageOpacity);
    Rect _srcRect = Offset(imgX, imgY) & const Size(imgSize, imgSize);
    Rect _dstRect = Offset(x - r, y - r) & Size(r * 2, r * 2);

    canvas.drawImageRect(imgs, _srcRect, _dstRect, _paint);
  }

  //stage collide effect
  void bounceStage(stage) {
    double _minX = r;
    double _maxX = stage.x - r;
    double _minY = r;
    double _maxY = stage.y - r;

    if (x <= _minX || x >= _maxX) vx = -vx;
    if (y <= _minY || y >= _maxY) vy = -vy;
  }

  //F = ma
  collide(b1, b2, dx, dy, d, score, Function soundType) {
    double _nx = dx / d;
    double _ny = dy / d;
    double _s = b1.r + b2.r - d;

    b1.x -= _nx * _s / 2;
    b1.y -= _ny * _s / 2;
    b2.x += _nx * _s / 2;
    b2.y += _ny * _s / 2;

    final _k = -2.00 *
        ((b2.vx - b1.vx) * _nx + (b2.vy - b1.vy) * _ny) /
        (1 / b1.r + 1 / b2.r);

    b1.vx -= _k * _nx / b1.r;
    b1.vy -= _k * _ny / b1.r;
    b2.vx += _k * _nx / b2.r;
    b2.vy += _k * _ny / b2.r;

    if (b1.isEnemy != b2.isEnemy) {
      soundType('collide.wav');
      b1.mana -= manaReduceSpeed;
      b2.mana -= manaReduceSpeed;
      score +=
          ((b1.vx.abs() + b1.vy.abs() + b2.vx.abs() + b2.vy.abs()) / 3).ceil();
    }

    return score;
  }

  Future<void> onLoad() async {}
}

class Circle {
  double x, y;
  dynamic imgs;
  Circle(this.x, this.y, this.imgs);

  double vx = 0;
  double vy = 0;
  double r = 6.0;
  var vaccineImagePos = _imgLocation['vc'];

  createBall(balls, stage) {
    balls.add(Ball(stage, r, 1, imgs));

    final int _lastIndex = balls.length - 1;
    const double _speedMax = 7.0;
    const double _speedMin = 5.0;
    final double _speedx =
        math.Random().nextDouble() * (_speedMax - _speedMin) + _speedMin;
    final double _speedy =
        math.Random().nextDouble() * (_speedMax - _speedMin) + _speedMin;

    balls[_lastIndex]
      ..vx = x > (stage.x / 2) ? -_speedx : _speedx
      ..vy = y > (stage.y / 2) ? -_speedy : _speedy
      ..isEnemy = false
      ..x = x
      ..y = y
      ..r = r
      ..mana = r * 0.7
      ..image = _imgLocation['vc'];
  }
}

class CollideSpark {
  Ball b1, b2;
  double dx, dy;
  dynamic imgs;
  CollideSpark(this.b1, this.b2, this.dx, this.dy, this.imgs);

  late double x = b1.x + (b1.r * math.cos(math.atan2(dy, dx)));
  late double y = b1.y + (b1.r * math.sin(math.atan2(dy, dx)));
  late double impactVolume =
      b1.vx.abs() + b1.vy.abs() + b2.vx.abs() + b2.vy.abs();
  double pointShowStatus = 0;
  late final List pointShowColor;

  Effects effects = Effects();
  late Map<String, double> pos = {
    'x': x,
    'y': y,
    'r': impactVolume,
  };

  late var sparkType = sparkTypeSelect(b1, b2);

  sparkTypeSelect(b1, b2) {
    Map<String, double> _sparkType;

    if (b1.isEnemy != b2.isEnemy) {
      _sparkType = _imgLocation['sparkLarge'];
      pos['r'] = impactVolume * 6;
      pointShowStatus = 75;
      pointShowColor = (b1.isEnemy) ? b1.image['rgb'] : b2.image['rgb'];
    } else {
      _sparkType = _imgLocation['sparkSmall'];
      pos['r'] = impactVolume * 3;
    }
    return _sparkType;
  }

  void sparkDraw(canvas, size) {
    Paint _paint = Paint()
      ..color = const Color.fromRGBO(0, 0, 0, 1)
      ..imageFilter = ui.ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0);
    Rect _srcRect =
        Offset(sparkType['x'], sparkType['y']) & const Size(imgSize, imgSize);
    Rect _dstRect = Offset(pos['x']! - pos['r']!, pos['y']! - pos['r']!) &
        Size(pos['r']! * 2, pos['r']! * 2);

    canvas.drawImageRect(imgs, _srcRect, _dstRect, _paint);

    if (pointShowStatus > 0) {
      final int vr = ((impactVolume) / 3).ceil();
      Effects.drawText(
        canvas,
        size,
        Offset(pos['x']!, pos['y']! - (75 - pointShowStatus).abs()),
        '+$vr',
        fontSize: 20,
        color: Color.fromRGBO(pointShowColor[0], pointShowColor[1],
            pointShowColor[2], pointShowStatus / 100 + 0.2),
      );
      pointShowStatus--;
    }
  }
}
