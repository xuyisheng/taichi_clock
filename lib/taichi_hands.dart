import 'dart:math';

import 'package:flutter/material.dart';
import 'package:taichi_clock/taichi_clock.dart';

class HourHandWidget extends CustomPainter {
  var hour;

  HourHandWidget(this.hour);

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = min(size.width, size.height) * 0.15;
    var rect = Rect.fromCircle(center: Offset(0, -size.height * 0.2), radius: radius * 1.2);

    final Gradient gradient = new LinearGradient(
      colors: [
        taichiTheme[Taichi.indicatorColor].withOpacity(0.1),
        taichiTheme[Taichi.indicatorColor],
      ],
    );

    final paintRange = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..shader = gradient.createShader(rect);

    canvas.translate(centerX, centerY);

    canvas.rotate(pi / 3);
    var startAngle = -pi / 2 - pi / 3;
    canvas.drawArc(rect, startAngle, 2 * pi * hour / 24, false, paintRange);

    canvas.translate(0, -size.height * 0.2);

    canvas.rotate(-pi / 3);
    var textPainter = TextPainter(
      text: TextSpan(
        text: hour.toString(),
        style: TextStyle(
          fontSize: radius,
          fontWeight: FontWeight.w500,
        ),
      ),
      textAlign: TextAlign.justify,
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter
      ..paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );

    canvas.save();
    for (int i = 0; i < hoursInChinese.length; i++) {
      var textPainter = TextPainter(
        text: TextSpan(
            text: hoursInChinese[i],
            style: TextStyle(
              fontSize: radius / 4,
              color: taichiTheme[Taichi.taichiDark],
            )),
        textAlign: TextAlign.justify,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter
        ..paint(
          canvas,
          Offset(-textPainter.width / 2, -(textPainter.height / 2) - radius),
        );
      canvas.rotate(2 * pi / hoursInChinese.length);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(HourHandWidget oldDelegate) {
    return oldDelegate.hour != hour;
  }
}

class MinutesWidget extends CustomPainter {
  final paintIndicator = Paint()
    ..color = taichiTheme[Taichi.indicatorColor]
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 2
    ..style = PaintingStyle.fill;
  var minute;

  MinutesWidget(this.minute);

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = min(size.width, size.height) * 0.15;

    canvas.translate(centerX, centerY);
    canvas.rotate(-pi * 2 / 3);
    canvas.translate(0, -size.height * 0.2);
    canvas.rotate(pi * 2 / 3);
    var textPainter = TextPainter(
      text: TextSpan(
        text: minute.toString().padLeft(2, '0'),
        style: TextStyle(
          fontSize: radius,
          color: taichiTheme[Taichi.taichiLight],
          fontWeight: FontWeight.w500,
        ),
      ),
      textAlign: TextAlign.justify,
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter
      ..paint(
        canvas,
        Offset(
          -textPainter.width / 2,
          -(textPainter.height / 2),
        ),
      );

    canvas.save();
    canvas.rotate(radiansPerTick * minute);
    canvas.drawLine(Offset(0, -radius * 0.9), Offset(0, -radius * 1.1), paintIndicator);
    canvas.restore();

    canvas.save();
    for (int i = 0; i < minutesInChinese.length; i++) {
      var textPainter = TextPainter(
        text: TextSpan(
          text: minutesInChinese[i],
          style: TextStyle(
            fontSize: radius / 4,
            color: taichiTheme[Taichi.taichiLight],
          ),
        ),
        textAlign: TextAlign.justify,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter
        ..paint(
          canvas,
          Offset(-textPainter.width / 2, -(textPainter.height / 2) - radius),
        );

      canvas.rotate(2 * pi / minutesInChinese.length);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(MinutesWidget oldDelegate) {
    return oldDelegate.minute != minute;
  }
}

class SecondHandWidget extends CustomPainter {
  final paintNumber = Paint()..color = taichiTheme[Taichi.numbers];

  final paintIndicator = Paint()
    ..color = taichiTheme[Taichi.indicatorColor]
    ..style = PaintingStyle.fill;

  final paintOutCircleStroke = Paint()
    ..color = taichiTheme[Taichi.shadow]
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  var offset;

  SecondHandWidget(this.offset);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = min(size.width, size.height) * 0.4;
    final paintOutCircle = Paint()
      ..color = taichiTheme[Taichi.taichiLight]
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius / 10;

    canvas.drawCircle(Offset(centerX, centerY), radius * 1.05, paintOutCircle);
    canvas.translate(centerX, centerY);
    canvas.rotate(pi / 2 + offset);

    /// Draw seconds num indicator
    for (int i = 0; i < 60; i++) {
      canvas.save();
      canvas.translate(0, -radius);
      canvas.rotate(-pi / 2);
      canvas.drawCircle(Offset(radius * 0.05, 0), radius / 60, paintNumber);
      canvas.restore();
      canvas.rotate(radiansPerTick);
    }
    canvas.restore();

    canvas.translate(centerX, centerY);
    canvas.drawCircle(Offset(radius * 1.05, 0), radius / 20, paintNumber);
    var textPainter = TextPainter(
      text: TextSpan(
        text: DateTime.now().second.toString(),
        style: TextStyle(
          fontSize: radius / 16,
          color: taichiTheme[Taichi.indicatorColor],
          fontWeight: FontWeight.bold,
        ),
      ),
      textAlign: TextAlign.justify,
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter
      ..paint(
        canvas,
        Offset(radius * 1.05 - textPainter.width / 2, -textPainter.height / 2),
      );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
