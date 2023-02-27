import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';

//import flame package(loop, gestures, audio)
import 'package:flame/input.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';

//import private flutter package
import 'package:flutter_application_1/bg_animation.dart';
import 'package:flutter_application_1/effects.dart';
import 'package:flutter_application_1/objects.dart';
import 'package:flutter_application_1/load_assets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setPortrait();
  MobileAds.instance.initialize();

  runApp(
    GameWidget(
      game: MyGame(),
    ),
  );
}

class MyGame extends FlameGame with TapDetector, LongPressDetector {
  final Map<String, dynamic> starInit = {
    'total': 100,
    'size': 2,
    'stsNearDist': 60,
    'stars': [],
  };
  late List<Ball> balls = [];
  late double myBalls;
  late double tmpRemainTime;
  Circle? circle;
  List<Ball> explosions = [];
  Effects effects = Effects();

  late int covidCount;
  late int vaccineCount;

  Map<String, bool> initBool = {
    'isDown': false,
    'isAlarm': false,
    'isPlay': false,
    'isGameOver': false,
    'isStart': true,
  };

  Map<String, dynamic> init = {
    'stageNo': 0,
    'sparks': [],
    'sparkSpeed': 10,
    'stageLimitTime': 91,
    'stageCountdown': 7.9,
    'stageIntervalTime': 0,
    'stagePreIntervalTime': 0,
    'countdownFontSize': 0,
  };

  Map<String, double> noticeBoard = {
    'totalKillCovid': 0,
    'stageKillCovid': 0,
    'stageRemainVaccine': 0,
    'bonusPoints': 0,
    'score': 0,
  };

  Map<String, double> endScene = {
    'endFontSize': 0,
    'replayImgSize': 96,
    'replayImgRotate': 0,
  };

  Map<String, List<double>> setBalls = {
    'ballTotal': [
      3,
      4,
      4,
      5,
      5,
      5,
      5,
      6,
      6,
      7,
      7,
      8,
      8,
      8,
      8,
      8,
      9,
      9,
      9,
      9,
      9,
      9,
      9,
      9,
      9
    ],
    'ballTime': [
      25,
      24,
      23,
      22,
      21,
      21,
      20,
      20,
      19,
      19,
      19,
      18,
      17,
      16,
      15,
      15,
      15,
      15,
      15,
      15,
      15,
      15,
      15,
      15,
      14
    ],
    'myBallTime': [
      5,
      5,
      5,
      6,
      6,
      6,
      6,
      7,
      7,
      7,
      7,
      7,
      7,
      7,
      7,
      8,
      8,
      8,
      8,
      8,
      8,
      8,
      8,
      9,
      9
    ],
    'ballVaccine': [
      35,
      30,
      30,
      28,
      25,
      23,
      22,
      21,
      20,
      20,
      20,
      20,
      20,
      20,
      20,
      19,
      18,
      18,
      18,
      17,
      16,
      16,
      15,
      15,
      14
    ],
    'ballSizeMin': [
      25,
      26,
      27,
      30,
      30,
      30,
      33,
      33,
      33,
      35,
      35,
      35,
      38,
      38,
      38,
      40,
      40,
      40,
      40,
      40,
      41,
      41,
      42,
      42,
      42
    ],
    'ballSizeMax': [
      35,
      35,
      40,
      41,
      42,
      43,
      44,
      45,
      46,
      47,
      48,
      49,
      50,
      50,
      50,
      50,
      50,
      50,
      50,
      50,
      51,
      52,
      53,
      54,
      55
    ],
    'ballRange': [
      3,
      3,
      3,
      4,
      4,
      5,
      5,
      5,
      6,
      6,
      6,
      6,
      6,
      6,
      6,
      6,
      6,
      6,
      6,
      6,
      6,
      6,
      6,
      6,
      6
    ],
  };

  List<CollideSpark> sparks = [];
  final sparkSpeed = 10;

  late dynamic imageGroup;

  final Paint bgPaint = Paint()..color = const Color.fromRGBO(0, 0, 0, 1);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    imageGroup = await loadImage();
    await FlameAudio.audioCache.loadAll([
      'appear.wav',
      'disappear.wav',
      'collide.wav',
      'explosion_large.mp3',
      'explosion_medium.mp3',
      'explosion_small.mp3',
      'gameover.mp3',
      'alarm.mp3',
    ]);
    startBgm();
    initBgStarAnimate(starInit, size);
    updateStage();
    _createInterstitialAd();
  }

  @override
  // ignore: must_call_super
  void render(Canvas canvas) {
    super.onLoad();
    animate(canvas);
  }

  // @override
  // // ignore: must_call_super
  // void update(double dt) {
  //   super.onLoad();
  // }

  late double startTimeStage,
      startTimeCovid,
      startTimeVaccine,
      createBallTimeCovid,
      createBallTimeVaccine;

  animate(canvas) {
    parallaxBg(canvas, size, imageGroup[0]);
    updateRenderBgStar(canvas, size, starInit, init['stageNo']);
    if (initBool['isStart']!) {
      welcomePage(canvas, size, imageGroup[4], imageGroup[5]);
      return;
    }
    double curTime = DateTime.now().millisecondsSinceEpoch / 1000;
    double diffTimeStage = curTime - startTimeStage;
    double diffTimeCovid = curTime - startTimeCovid;
    double diffTimeVaccine = curTime - startTimeVaccine;

    if (diffTimeCovid > createBallTimeCovid && initBool['isPlay']!) {
      final sMax = setBalls['ballSizeMax']![init['stageNo'] - 1];
      final sMin = setBalls['ballSizeMin']![init['stageNo'] - 1];
      final range = setBalls['ballRange']![init['stageNo'] - 1];
      final radius = math.Random().nextDouble() * (sMax - sMin) + sMin;

      balls.add(Ball(size, radius, range, imageGroup[1]));
      soundType('appear.wav');
      startTimeCovid = getTime();
    }

    if (diffTimeVaccine > createBallTimeVaccine && initBool['isPlay']!) {
      myBalls++;
      startTimeVaccine = getTime();
    }

    drawBalls(canvas, size);

    final Map<String, dynamic> getCurStatus = {
      'dtStage': diffTimeStage,
      'dtC': diffTimeCovid,
      'dtV': diffTimeVaccine,
      'myBalls': myBalls,
      'createDtc': createBallTimeCovid,
      'createDtv': createBallTimeVaccine,
      'score': noticeBoard['score'],
      'stageLimitTime': init['stageLimitTime'],
    };
    double remainTime = (!initBool['isGameOver']! && initBool['isPlay']!)
        ? effects.curStatusDraw(canvas, size, getCurStatus)
        : 0;

    if (covidCount < 1) {
      clearStage(canvas, size, remainTime);
    }
    if (remainTime <= 0.05 && covidCount > 0) {
      gameOver(canvas, size);
    }
    if (remainTime <= 6 && !initBool['isAlarm']! && covidCount > 1) {
      FlameAudio.bgm.pause();
      soundType('alarm.mp3');
      initBool['isAlarm'] = true;
    }

    if (circle != null && initBool['isDown']!) {
      drawCircle(canvas, size, balls);
    }
  }

  gameOver(canvas, size) {
    if (!initBool['isGameOver']!) {
      soundType('gameover.mp3');
    }

    initBool['isGameOver'] = true;
    initBool['isPlay'] = false;
    startTimeStage = getTime();
    myBalls = 0;

    for (var ball in balls) {
      ball.mana = (!ball.isEnemy || ball.expStatus > 0) ? 0 : ball.mana;
    }

    effects.gameOverDraw(canvas, size, imageGroup[3], endScene, noticeBoard);
  }

  startButtonTapCheck(touchPoint, _imgX, _imgY, imgSize) {
    final buttonJudg = math.sqrt(
        math.pow(touchPoint.x - _imgX, 2) + math.pow(touchPoint.y - _imgY, 2));
    return (buttonJudg <= imgSize / 2) ? true : false;
  }

  // create small vaccine
  @override
  void onTapUp(TapUpInfo info) {
    final touchPoint = info.eventPosition.game;
    double _x = touchPoint.x;
    double _y = touchPoint.y;

    if (initBool['isStart']!) {
      if (startButtonTapCheck(touchPoint, size.x * 0.5, size.y * 0.65, 160.0)) {
        initBool['isStart'] = false;
        init['stageNo'] = 0;
        soundType('stage_start.mp3');
        return updateStage();
      }
    }

    if (initBool['isGameOver']!) {
      if (startButtonTapCheck(
          touchPoint, size.x * 0.5, size.y * 0.85, endScene['replayImgSize'])) {
        pauseEngine();
        _showInterstitialAd();
      }
    }

    if (_x > 0 && _y > 0 && _x < canvasSize.x && _y < canvasSize.y) {
      List<bool> _distCheck = [];

      for (var ball in balls) {
        double _dist =
            math.sqrt(math.pow(_x - ball.x, 2) + math.pow(_y - ball.y, 2));
        _distCheck.add(_dist > ball.r);
      }

      if (_distCheck.every((element) => true) && myBalls > 0) {
        Circle(_x, _y, imageGroup[1]).createBall(balls, size);
        soundType('appear.wav');
        myBalls--;
      }
    }
  }

  // create large vaccine
  @override
  void onLongPressStart(LongPressStartInfo info) {
    final _touchPoint = info.eventPosition.game;
    double _x = _touchPoint.x;
    double _y = _touchPoint.y;

    if (_x > 0 && _y > 0 && _x < canvasSize.x && _y < canvasSize.y) {
      List<bool> _distCheck = [];

      for (var ball in balls) {
        double _dist =
            math.sqrt(math.pow(_x - ball.x, 2) + math.pow(_y - ball.y, 2));
        _distCheck.add(_dist > ball.r);
      }

      if (_distCheck.every((element) => true) && myBalls > 0) {
        circle = Circle(_x, _y, imageGroup[1]);
        initBool['isDown'] = true;
        myBalls--;
      }
    }
  }

  @override
  void onLongPressMoveUpdate(LongPressMoveUpdateInfo info) {
    final touchPoint = info.eventPosition.game;
    if (circle == null) return;
    circle!.x = touchPoint.x;
    circle!.y = touchPoint.y;
  }

  @override
  void onLongPressEnd(LongPressEndInfo info) {
    if (circle != null && initBool['isDown']!) {
      circle!.createBall(balls, size);
      soundType('appear.wav');
    }
    initBool['isDown'] = false;
    circle = null;
  }

  drawCircle(canvas, stage, ball) {
    if (!initBool['isDown']! || circle == null) return;
    final double _maxRadius = stage.x / 4;
    const double _sizeUpSpeed = 0.3;
    final cc = circle!;

    (cc.r < _maxRadius) ? cc.r += _sizeUpSpeed : '';

    if (cc.x + cc.r >= stage.x) cc.x = stage.x - cc.r - 1;
    if (cc.x - cc.r <= 0) cc.x = cc.r + 1;
    if (cc.y + cc.r >= stage.y) cc.y = stage.y - cc.r - 1;
    if (cc.y - cc.r <= 0) cc.y = cc.r + 1;

    collideCircle(balls);

    Paint _paint = Paint()..color = const Color.fromRGBO(0, 0, 0, 0.7);
    Rect _srcRect = Offset(cc.vaccineImagePos['x'], cc.vaccineImagePos['y']) &
        Size(cc.vaccineImagePos['size'], cc.vaccineImagePos['size']);
    Rect _dstRect = Offset(cc.x - cc.r, cc.y - cc.r) & Size(cc.r * 2, cc.r * 2);
    canvas.drawImageRect(imageGroup[1], _srcRect, _dstRect, _paint);
  }

  collideCircle(balls) {
    for (int i = 0; i < balls.length; i++) {
      double _dx = balls[i].x - circle!.x;
      double _dy = balls[i].y - circle!.y;
      double _d = math.sqrt(math.pow(_dx, 2) + math.pow(_dy, 2));

      if (_d <= balls[i].r + circle!.r) {
        if (!balls[i].isEnemy) {
          circle!.createBall(balls, size);
          soundType('appear.wav');
        } else {
          soundType('disappear.wav');
        }

        initBool['isDown'] = false;
        circle = null;
        return;
      }
    }
  }

  final maxBallCovid = 12;
  final maxBallVaccine = 50;
  // draw COVID & Vaccine
  void drawBalls(canvas, size) {
    covidCount = 0;
    vaccineCount = 0;

    for (int i = 0; i < balls.length; i++) {
      (balls[i].isEnemy) ? covidCount++ : vaccineCount++;

      if (balls[i].mana < 4) {
        if (balls[i].isEnemy) {
          noticeBoard['score'] = noticeBoard['score']! + (balls[i].r).floor();
          noticeBoard['stageKillCovid'] = noticeBoard['stageKillCovid']! + 1;
          noticeBoard['totalKillCovid'] = noticeBoard['totalKillCovid']! + 1;
        }
        (balls[i].r <= 10)
            ? soundType('explosion_small.mp3')
            : (balls[i].r <= 25)
                ? soundType('explosion_medium.mp3')
                : soundType('explosion_large.mp3');
        explosions.add(balls[i]);
        balls.removeAt(i);
        i--;
      } else {
        balls[i].draw(canvas, size);
      }

      if (covidCount >= maxBallCovid) startTimeCovid = getTime();
      if (myBalls >= maxBallVaccine) startTimeVaccine = getTime();
    }

    checkCollideBall(canvas);

    List<Ball> _filterExplosions = explosions.where((e) => e.r > 0).toList();

    if (_filterExplosions.isNotEmpty) {
      for (Ball expEach in _filterExplosions) {
        expEach.effects.explosion(canvas, size, expEach, imageGroup[2]);
      }
    }
    explosions = _filterExplosions;
  }

  //check collide ball & draw sparks
  void checkCollideBall(canvas) {
    for (int i = 0; i < balls.length - 1; i++) {
      for (int j = i + 1; j < balls.length; j++) {
        double _dx = balls[j].x - balls[i].x;
        double _dy = balls[j].y - balls[i].y;
        double _d = math.sqrt(math.pow(_dx, 2) + math.pow(_dy, 2));

        if (_d < (balls[i].r + balls[j].r) &&
            !balls[i].expStatus.isNaN &&
            !balls[j].expStatus.isNaN) {
          noticeBoard['score'] = balls[j].collide(balls[i], balls[j], _dx, _dy,
              _d, noticeBoard['score'], soundType);
          sparks.add(CollideSpark(balls[i], balls[j], _dx, _dy, imageGroup[1]));
        }
      }
    }

    if (sparks.isNotEmpty) {
      final List<CollideSpark> _filterSparks = sparks
          .where((_spark) => _spark.pos['r']! > 0 || _spark.pointShowStatus > 0)
          .toList();
      sparks = _filterSparks;
      for (CollideSpark _spark in sparks) {
        _spark.sparkDraw(canvas, size);
        _spark.pos['r'] = _spark.pos['r']! - sparkSpeed;
      }
    }
  }

  double getTime() {
    return DateTime.now().millisecondsSinceEpoch / 1000;
  }

  //clear stage
  void clearStage(canvas, size, remainTime) {
    if (remainTime > 0) {
      tmpRemainTime = remainTime;
    }

    startTimeStage = getTime();
    initBool['isPlay'] = false;

    if (init['stagePreIntervalTime'] == 0) {
      init['stagePreIntervalTime'] = getTime();
    }

    final tmp = getTime() - init['stagePreIntervalTime'];
    if (tmp < 1.5 && init['stageNo'] > 0) return;

    if (init['stageIntervalTime'] == 0) {
      init['stageIntervalTime'] = getTime();
    }
    double dTime = getTime() - init['stageIntervalTime'];

    if (remainTime > 0 || myBalls > 0) {
      noticeBoard['bonusPoints'] = remainTime * 2 + myBalls * 10;
      noticeBoard['stageRemainVaccine'] = myBalls;
    }

    if (init['stageNo'] > 0) {
      effects.clearStageMessage(canvas, size, init, noticeBoard, tmpRemainTime);
    }

    if (dTime == 0.0) {
      FlameAudio.bgm.pause();
      soundType('stage_win.mp3');
    }
    effects.clearStageCountdown(canvas, size, dTime, init);
    myBalls = 0;

    //get new stage
    if (init['stageCountdown'] - dTime <= 0.05) {
      init['stageIntervalTime'] = 0;
      init['stagePreIntervalTime'] = 0;
      updateStage();
    }
  }

  //update new stage
  void updateStage() {
    FlameAudio.bgm.resume();
    if (init['stageNo']! >= setBalls['ballRange']!.length) {
      init['stageNo'] = 0;
    }
    final index = init['stageNo'];

    init['stageNo']++;
    initBool['isPlay'] = true;
    initBool['isAlarm'] = false;
    endScene['endFontSize'] = 0;
    init['countdownFontSize'] = 0;
    balls.clear();

    startTimeStage = getTime();
    startTimeCovid = getTime();
    startTimeVaccine = getTime();

    noticeBoard['score'] = noticeBoard['score']! + noticeBoard['bonusPoints']!;
    noticeBoard['bonusPoint'] = 0;
    noticeBoard['stageKillCovid'] = 0;

    createBallTimeCovid = setBalls['ballTime']![index];
    createBallTimeVaccine = setBalls['myBallTime']![index];
    myBalls = setBalls['ballVaccine']![index];

    final sMax = setBalls['ballSizeMax']![index];
    final sMin = setBalls['ballSizeMin']![index];

    for (int i = 0; i < setBalls['ballTotal']![index]; i++) {
      final radius = math.Random().nextDouble() * (sMax - sMin) + sMin;
      balls.add(
          Ball(size, radius, setBalls['ballRange']![index], imageGroup[1]));
    }
  }

  welcomePage(canvas, size, logoImg, startImg) {
    Effects.drawText(
      canvas,
      size,
      Offset(0.0, size.y * 0.88),
      'You can make a vaccine ball to fight off the virus by a short or long touch on the screen.',
      fontSize: size.x / 13,
      //fontName: '',
      color: const Color.fromRGBO(70, 226, 253, 0.9),
      align: TextAlign.center,
    );
    final logoImgSize = size.x * 0.9;
    Paint _paint = Paint()..color = const Color.fromRGBO(0, 0, 0, 1);
    Rect _srcRect = const Offset(0.0, 0.0) & const Size(960.0, 960.0);
    Rect _dstRect = Offset(size.x / 2 - (logoImgSize / 2), size.y * 0.05) &
        Size(logoImgSize, logoImgSize);
    canvas.drawImageRect(logoImg, _srcRect, _dstRect, _paint);

    final startImgSize = size.x / 2;
    _paint = Paint()..color = const Color.fromRGBO(0, 0, 0, 0.9);
    _srcRect = const Offset(0.0, 0.0) & const Size(960.0, 960.0);
    _dstRect = Offset(size.x / 2 - (startImgSize / 2), size.y * 0.5) &
        Size(startImgSize, startImgSize);

    canvas.drawImageRect(startImg, _srcRect, _dstRect, _paint);
  }

  startBgm() {
    FlameAudio.bgm.initialize();
    FlameAudio.bgm.play('main_theme.mp3');
  }

  soundType(String type) {
    // FlameAudio.audioCache.play(type);
  }

  replayInit() {
    resumeEngine(); //restart rendering

    init['stageNo'] = 0;
    initBool = {
      'isDown': false,
      'isAlarm': false,
      'isPlay': true,
      'isGameOver': false,
      'isStart': false,
    };
    noticeBoard = {
      'totalKillCovid': 0,
      'stageKillCovid': 0,
      'stageRemainVaccine': 0,
      'bonusPoints': 0,
      'score': 0,
    };
    soundType('stage_start.mp3');
    return updateStage();
  }

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  final int maxFailedLoadAttempts = 3;

  void _createInterstitialAd() {
    //const String androidId = 'ca-app-pub-2489741092366129/4905779498';
    const String androidTestId = 'ca-app-pub-3940256099942544/1033173712';
    const String iosTestId = 'ca-app-pub-3940256099942544/4411468910';
    InterstitialAd.load(
        adUnitId: Platform.isAndroid ? androidTestId : iosTestId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            // print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      //print('Warning: attempt to show interstitial before loaded.');
      replayInit();
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        replayInit();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        //print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        replayInit();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }
}//main block

  
