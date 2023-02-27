import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:intl/intl.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Effects {
  void explosion(canvas, size, target, expImages) {
    const totalExpImage = 48;
    double r = target.r * 1.5;
    const double imgSize = 256.0;
    final Map<String, dynamic> imgPos = {
      'x': (target.expStatus % 8) * imgSize + 1,
      'y': (target.expStatus ~/ 8) * imgSize + 1,
    };
    canvas.save();
    canvas.translate(target.x, target.y);
    canvas.rotate(target.rotate * math.pi / 180);
    canvas.translate(-target.x, -target.y);

    Paint _paint = Paint()
      ..color = const Color.fromRGBO(0, 0, 0, 1)
      ..imageFilter = ui.ImageFilter.blur(sigmaX: .7, sigmaY: .7);
    Rect _srcRect =
        Offset(imgPos['x'], imgPos['y']) & const Size(imgSize, imgSize);
    Rect _dstRect =
        Offset(target.x - r * 2, target.y - r * 2) & Size(r * 4, r * 4);

    canvas.drawImageRect(expImages, _srcRect, _dstRect, _paint);
    canvas.restore();

    if (target.isEnemy) {
      drawText(canvas, size, Offset(target.x, target.y + target.expStatus),
          '+${r.toInt()}',
          fontSize: 25,
          color: ui.Color.fromRGBO(255, 42, 42, 0.9 - target.expStatus / 100));
    }
    (target.expStatus < totalExpImage) ? target.expStatus++ : target.r = 0.0;
  }

  clearStageMessage(canvas, size, init, noticeBoard, tmpRemainTime) {
    final double fontSize = init['countdownFontSize'] * 0.7;
    final stageNo = _convertOrdinalNumber(init['stageNo'].toInt());

    drawText(
      canvas,
      size,
      Offset(0.0, size.y * 0.2),
      stageNo.toString() + ' stage',
      fontSize: fontSize,
      color: const ui.Color.fromRGBO(56, 93, 255, 0.9),
      align: TextAlign.center,
    );
    drawText(
      canvas,
      size,
      Offset(0.0, size.y * 0.2 + fontSize * 1.1),
      'Clear!',
      fontSize: fontSize,
      color: const ui.Color.fromRGBO(56, 93, 255, 0.9),
      align: TextAlign.center,
    );

    final List<String> items = [
      'Removed Virus',
      'Remain Time',
      'Spare Vaccine',
      'Bonus Points',
      'Total Score'
    ];
    final List<dynamic> values = [
      noticeBoard['stageKillCovid'].toInt(),
      '${tmpRemainTime.toInt()} s',
      noticeBoard['stageRemainVaccine'].toInt(),
      noticeBoard['bonusPoints'].toInt(),
      _scoreWithComma(
          (noticeBoard['score'] + noticeBoard['bonusPoints']).toInt()),
    ];

    for (int i = 0; i < items.length; i++) {
      double posY = (size.y * 0.2 + fontSize * 2.1) + (fontSize * 0.65 * i);
      drawText(
        canvas,
        size,
        Offset(fontSize / 2, posY),
        items[i],
        fontSize: fontSize * 0.45,
        color: const ui.Color.fromRGBO(250, 234, 93, 0.8),
        align: TextAlign.left,
      );
      drawText(
        canvas,
        size,
        Offset(-fontSize / 2, posY),
        '${values[i]}',
        fontSize: fontSize * 0.45,
        color: const ui.Color.fromRGBO(250, 103, 93, 0.9),
        align: TextAlign.right,
      );
    }
  }

  _convertOrdinalNumber(n) {
    const List<String> _suffix = ['th', 'st', 'nd', 'rd'];
    if (n >= 11 && 20 >= n) {
      return '$n${_suffix[0]}';
    } else if ((n % 10) >= 4) {
      return '$n${_suffix[0]}';
    } else {
      return '$n${_suffix[n % 10]}';
    }
  }

  clearStageCountdown(canvas, size, dTime, init) {
    final double maxFontSize = math.min(size.x / 4, 200);
    final Offset pos = Offset(0.0, size.y * 0.85);
    final stageCountdown = (init['stageCountdown'] - dTime.floor()).toInt();

    init['countdownFontSize'] = (maxFontSize > init['countdownFontSize'])
        ? init['countdownFontSize'] += 5
        : maxFontSize;

    drawText(
      canvas,
      size,
      pos,
      stageCountdown.toString(),
      fontSize: init['countdownFontSize'] * 1.1,
      fontName: 'Black Ops One',
      color: const ui.Color.fromRGBO(56, 255, 139, 0.9),
      align: TextAlign.center,
    );
  }

  gameOverDraw(canvas, size, replayImg, endScene, noticeBoard) {
    final imgSize = endScene['replayImgSize'];
    final double maxFontSize = math.min(size.x * 0.2, 200.0);
    final Map<String, double> replayButton = {
      'x': size.x * 0.5,
      'y': size.y * 0.85,
    };

    endScene['endFontSize'] = (maxFontSize > endScene['endFontSize'])
        ? endScene['endFontSize'] += 5.0
        : maxFontSize;
    endScene['replayImgRotate'] = (endScene['replayImgRotate'] < 360)
        ? endScene['replayImgRotate'] += 2.0
        : 0.0;

    drawText(
      canvas,
      size,
      Offset(0.0, size.y * 0.22),
      'GAME',
      fontSize: endScene['endFontSize'] * 1.1,
      fontName: 'Black Ops One',
      color: const Color.fromRGBO(255, 50, 50, 0.9),
      align: TextAlign.center,
    );
    drawText(
      canvas,
      size,
      Offset(0.0, size.y * 0.22 + endScene['endFontSize']),
      'OVER',
      fontSize: endScene['endFontSize'] * 1.1,
      fontName: 'Black Ops One',
      color: const Color.fromRGBO(255, 50, 50, 0.9),
      align: TextAlign.center,
    );

    drawText(
      canvas,
      size,
      Offset(0.0, size.y * 0.2 + endScene['endFontSize'] * 2.5),
      'Total Removed Virus',
      fontSize: endScene['endFontSize'] / 3,
      color: const Color.fromRGBO(250, 234, 93, 0.9),
      align: TextAlign.center,
    );

    drawText(
      canvas,
      size,
      Offset(0.0, size.y * 0.2 + endScene['endFontSize'] * 3.0),
      noticeBoard['totalKillCovid'].toInt().toString(),
      fontSize: endScene['endFontSize'] / 3 * 1.4,
      color: const ui.Color.fromRGBO(186, 236, 233, 0.9),
      align: TextAlign.center,
      fontName: 'Black Ops One',
    );

    drawText(
      canvas,
      size,
      Offset(0.0, size.y * 0.2 + endScene['endFontSize'] * 3.8),
      'Your Total Score!',
      fontSize: endScene['endFontSize'] / 3,
      color: const Color.fromRGBO(250, 234, 93, 0.9),
      align: TextAlign.center,
    );

    drawText(
      canvas,
      size,
      Offset(0.0, size.y * 0.2 + endScene['endFontSize'] * 4.3),
      _scoreWithComma(noticeBoard['score'].toInt()),
      fontSize: endScene['endFontSize'] / 3 * 1.4,
      color: const ui.Color.fromRGBO(186, 236, 233, 0.9),
      align: TextAlign.center,
      fontName: 'Black Ops One',
    );

    canvas.save();
    canvas.translate(
      replayButton['x'],
      replayButton['y'],
    );
    canvas.rotate(endScene['replayImgRotate'] * (math.pi / -180));
    canvas.translate(
      replayButton['x']! * -1,
      replayButton['y']! * -1,
    );
    Paint _paint = Paint()
      ..color = const Color.fromRGBO(0, 0, 0, 0.8)
      ..imageFilter = ui.ImageFilter.blur(sigmaX: .6, sigmaY: .6);
    Rect _srcRect = const Offset(0.0, 0.0) & Size(imgSize, imgSize);
    Rect _dstRect = Offset(replayButton['x']! - imgSize / 2,
            replayButton['y']! - imgSize / 2) &
        Size(imgSize, imgSize);
    canvas.drawImageRect(replayImg, _srcRect, _dstRect, _paint);
    canvas.restore();
  }

  static drawText(canvas, size, Offset position, String text,
      {String fontName = 'Skranji',
      double fontSize = 18.0,
      Color color = const Color.fromRGBO(187, 240, 250, 0.7),
      final align = TextAlign.start}) {
    final textStyle = TextStyle(
      fontFamily: fontName,
      color: color,
      fontSize: fontSize,
    );
    var textSpan = TextSpan(
      text: text,
      style: textStyle,
    );
    final textPainter = TextPainter(
        text: textSpan, textDirection: ui.TextDirection.ltr, textAlign: align);

    textPainter.layout(minWidth: size.x, maxWidth: size.x);
    Offset drawPosition =
        Offset(position.dx, position.dy - (textPainter.height / 2));
    textPainter.paint(canvas, drawPosition);
  }

  curStatusDraw(canvas, size, cur) {
    // 'dtStage': diffTimeStage,
    // 'dtC': diffTimeCovid,
    // 'dtV': diffTimeVaccine,
    // 'myBalls': myBalls,
    // 'createDtc': createBallTimeCovid,
    // 'createDtv': createBallTimeVaccine,
    // 'score': noticeBoard['score'],
    // 'stageLimitTime': init['stageLimitTime'],
    var dTimeCovid = cur['dtC'] / cur['createDtc'];
    var dTimeVaccine = cur['dtV'] / cur['createDtv'];

    final Rect _rect1 = Rect.fromLTWH(size.x / 2 - 55, 20.0, 30.0, 30.0);
    final Rect _rect2 = Rect.fromLTWH(size.x / 2 + 140, 20.0, 30.0, 30.0);
    final Paint _paintStroke = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 1.5
      ..color = const Color.fromRGBO(200, 255, 255, 0.8)
      ..style = PaintingStyle.stroke;
    final Paint _paintFillCovid = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 1.5
      ..color = const Color.fromRGBO(255, 88, 116, 0.6)
      ..style = PaintingStyle.fill;
    final Paint _paintFillVaccine = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 1.5
      ..color = const Color.fromRGBO(78, 104, 255, 0.6)
      ..style = PaintingStyle.fill;

    canvas.drawArc(_rect1, 10.0, 20.0, false, _paintStroke);
    canvas.drawArc(
        _rect1, -1.5, math.pi * (dTimeCovid * 2), true, _paintFillCovid);
    canvas.drawLine(Offset(size.x / 2 - 40, 20.0),
        Offset(size.x / 2 - 40, 35.0), _paintStroke);

    canvas.drawArc(_rect2, 10.0, 20.0, false, _paintStroke);
    canvas.drawArc(
        _rect2, -1.5, math.pi * (dTimeVaccine * 2), true, _paintFillVaccine);
    canvas.drawLine(Offset(size.x / 2 + 155, 20.0),
        Offset(size.x / 2 + 155, 35.0), _paintStroke);
// drawText(canvas, size, position, text,
//       {String fontName = 'Skranji',
//       double fontSize = 18.0,
//       Color color = const Color.fromRGBO(200, 255, 255, 0.8),
//       final align = TextAlign.start})
    drawText(
      canvas,
      size,
      Offset(size.x / 2 - 175, 35),
      'New Virus',
    );
    drawText(
      canvas,
      size,
      Offset(size.x / 2 + 10, 35),
      'New Vaccine',
    );

    drawText(
      canvas,
      size,
      Offset(size.x / 2 - 175, 75),
      'Score : ${_scoreWithComma(cur['score'].toInt())}',
      fontSize: 25,
      color: const ui.Color.fromRGBO(255, 152, 111, 0.7),
    );
    drawText(
      canvas,
      size,
      Offset(size.x / 2 + 10, 75),
      'Remain Vacc. : ${cur['myBalls'].toInt()}',
    );

    final min = (cur['stageLimitTime'] - cur['dtStage']) ~/ 60;
    final sec = ((cur['stageLimitTime'] - cur['dtStage']) % 60).floor();
    final withZeroSec = (sec > 9) ? '$sec' : '0$sec';
    final color = (cur['stageLimitTime'] - cur['dtStage'] > 5)
        ? const ui.Color.fromRGBO(250, 234, 93, 0.7)
        : const ui.Color.fromRGBO(255, 88, 82, 0.7);

    drawText(
      canvas,
      size,
      Offset(0.0, size.y * 0.96),
      '$min : $withZeroSec',
      fontName: 'Black Ops One',
      fontSize: 30.0,
      align: TextAlign.center,
      color: color,
    );

    return (cur['stageLimitTime'] - cur['dtStage']).toDouble();
  }

  _scoreWithComma(n) {
    return NumberFormat('###,###,###').format(n).replaceAll(' ', '');
  }
}
