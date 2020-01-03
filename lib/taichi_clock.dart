import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:taichi_clock/taichi_background.dart';
import 'package:taichi_clock/taichi_hands.dart';
import 'package:vector_math/vector_math_64.dart' show radians;

/// Hours text of Chinese traditional time
final hoursInChinese = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];

/// Minutes text of Chinese traditional time
final minutesInChinese = ['圆', '|', '拾', '|', '廿', '|', '卅', '|', '卌', '|', '圩', '|'];
final weekdayList = ['Mon', 'Tues', 'Wed', 'Thur', 'Fri', 'Sat', 'Sun'];
final monthList = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/// Mock data of weather
final weatherList = [Icons.cloud, Icons.wb_sunny];

/// Mock data of location
final locationList = ['Shanghai', 'Hangzhou', 'BeiJing'];

enum Taichi {
  background,
  taichiLight,
  taichiDark,
  numbers,
  indicatorColor,
  shadow,
}

/// Theme data of Taichi
final taichiTheme = {
  Taichi.background: Color.fromARGB(255, 175, 210, 237),
  Taichi.taichiLight: Color.fromARGB(255, 14, 88, 142),
  Taichi.taichiDark: Color.fromARGB(255, 215, 235, 252),
  Taichi.numbers: Color.fromARGB(255, 210, 235, 254),
  Taichi.indicatorColor: Color.fromARGB(255, 252, 154, 48),
  Taichi.shadow: Color.fromARGB(255, 59, 109, 154),
};

/// Total distance traveled by a second or a minute hand, each second or minute, respectively.
final radiansPerTick = radians(360 / 60);

/// Total distance traveled by an hour hand, each hour, in radians.
final radiansPerHour = radians(360 / 24);

class _BounceOutCurve extends Curve {
  const _BounceOutCurve._();

  @override
  double transform(double t) {
    t -= 1.0;
    return t * t * (3 * t + 2) + 1.0;
  }
}

class ClockWidget extends StatefulWidget {
  @override
  _ClockWidgetState createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> with SingleTickerProviderStateMixin {
  final temperature = Random().nextInt(35).clamp(15, 35);
  final location = locationList[Random().nextInt(3)];
  final weather = weatherList[Random().nextInt(2)];

  var secondOffset = 0.0;
  var hourNum = 0;
  var minuteNum = 0;
  var showDate;

  DateTime datetime;
  Timer timer;

  /// Second hand animation
  AnimationController controller;
  Animation animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    updateTime();
    startAnim();

    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      startAnim();
      updateTime();
      setState(() {});
    });
  }

  void updateTime() {
    datetime = DateTime.now();
    hourNum = datetime.hour;
    minuteNum = datetime.minute;
    secondOffset = datetime.second * radiansPerTick;
    showDate = '${weekdayList[datetime.weekday - 1]}\n${monthList[datetime.month - 1]} ${datetime.day}';
  }

  void startAnim() {
    animation = Tween(begin: secondOffset, end: secondOffset + radiansPerTick).animate(
      CurvedAnimation(
        parent: controller,
        curve: _BounceOutCurve._(),
      ),
    );
    secondOffset += radiansPerTick;
    controller.reset();
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: AspectRatio(
          aspectRatio: 5 / 3,
          child: Container(
            width: double.infinity,
            color: taichiTheme[Taichi.background],
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    /// background
                    CustomPaint(
                      painter: TaiChiWidget(),
                    ),

                    /// Second hand
                    AnimatedBuilder(
                      builder: (context, widget) {
                        return CustomPaint(
                          painter: SecondHandWidget(animation.value),
                        );
                      },
                      animation: animation,
                    ),

                    /// Hour hand
                    CustomPaint(
                      painter: HourHandWidget(hourNum),
                    ),

                    /// Minute hand
                    CustomPaint(
                      painter: MinutesWidget(minuteNum),
                    ),

                    /// Date
                    Positioned(
                      child: Text(
                        showDate,
                        style: TextStyle(
                          fontSize: constraints.maxWidth / 33,
                          color: taichiTheme[Taichi.taichiLight],
                        ),
                      ),
                      top: constraints.maxHeight * 0.23,
                      left: constraints.maxWidth * 0.35,
                    ),

                    /// Weather and location
                    Positioned(
                      child: ExtraInfo(
                        weather: weather,
                        location: location,
                        temperature: temperature,
                        maxWidth: constraints.maxWidth,
                      ),
                      top: constraints.maxHeight * 0.6,
                      left: constraints.maxWidth * 0.55,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class ExtraInfo extends StatelessWidget {
  const ExtraInfo({
    Key key,
    @required this.weather,
    @required this.location,
    @required this.temperature,
    @required this.maxWidth,
  }) : super(key: key);

  final IconData weather;
  final String location;
  final num temperature;
  final num maxWidth;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(
          weather,
          color: taichiTheme[Taichi.taichiDark],
          size: maxWidth / 20,
        ),
        Text(
          location,
          style: TextStyle(
            fontSize: maxWidth / 40,
            color: taichiTheme[Taichi.taichiDark],
          ),
        ),
        Text(
          '$temperature℃',
          style: TextStyle(
            fontSize: maxWidth / 40,
            color: taichiTheme[Taichi.taichiDark],
          ),
        )
      ],
    );
  }
}
