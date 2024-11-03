import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lottie/lottie.dart';

const spots = [
  FlSpot(1.68, 21.04),
  FlSpot(2.84, 26.23),
  FlSpot(5.19, 19.82),
  FlSpot(6.01, 24.49),
  FlSpot(7.81, 19.82),
  FlSpot(9.49, 23.50),
  FlSpot(12.26, 19.57),
  FlSpot(15.63, 20.90),
  FlSpot(20.39, 39.20),
  FlSpot(23.69, 75.62),
  FlSpot(26.21, 46.58),
  FlSpot(29.87, 42.97),
  FlSpot(32.49, 46.54),
  FlSpot(35.09, 40.72),
  FlSpot(38.74, 43.18),
  FlSpot(41.47, 59.91),
  FlSpot(43.12, 53.18),
  FlSpot(46.30, 90.10),
  FlSpot(47.88, 81.59),
  FlSpot(51.71, 75.53),
  FlSpot(54.21, 78.95),
  FlSpot(55.23, 86.94),
  FlSpot(57.40, 78.98),
  FlSpot(60.49, 74.38),
  FlSpot(64.30, 48.34),
  FlSpot(67.17, 70.74),
  FlSpot(70.35, 75.43),
  FlSpot(73.39, 69.88),
  FlSpot(75.87, 80.04),
  FlSpot(77.32, 74.38),
  FlSpot(81.43, 68.43),
  FlSpot(86.12, 69.45),
  FlSpot(90.06, 78.60),
  FlSpot(94.68, 46.05),
  FlSpot(98.35, 42.80),
  FlSpot(101.25, 53.05),
  FlSpot(103.07, 46.06),
  FlSpot(106.65, 42.31),
  FlSpot(108.20, 32.64),
  FlSpot(110.40, 45.14),
  FlSpot(114.24, 53.27),
  FlSpot(116.60, 42.13),
  FlSpot(118.52, 57.60),
];


typedef DialogOptionBuilder<T>=Map<String,dynamic> Function();

Future<T?> showGenericDialog<T>({required BuildContext context,required String message,required String tittle ,required DialogOptionBuilder optionBuilder}){
  final options = optionBuilder();
  return showDialog<T?>(context: context, builder:(context){
    return AlertDialog(
      title: Text(tittle),
      content: Text(message),
      actions: options.keys.map((optionTitle){
        final value =options[optionTitle];
        return TextButton(onPressed: () {
          if(value!=null){
            Navigator.of(context).pop(value);
          }else{
            Navigator.of(context).pop();
          }
        }, child: Text(optionTitle));

      }).toList(),
    );
  }
  );
}

class WaterAnimation extends StatefulWidget {
  final Text receivedText;
  final double waterLevel;
  const WaterAnimation({super.key, required this.receivedText,required this.waterLevel});

  @override
  _WaterAnimationState createState() => _WaterAnimationState();
}

class _WaterAnimationState extends State<WaterAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blue, width: 4),
          ),
          child: ClipOval(
            child: CustomPaint(
              painter: WaterPainter(
                waterLevel: widget.waterLevel,
                animation: _animationController,
              ),
            ),
          ),
        ),
        // Text showing the water percentage
        widget.receivedText,
      ],
    );
  }
}

class WaterPainter extends CustomPainter {
  final double waterLevel;
  final Animation<double> animation;

  WaterPainter({required this.waterLevel, required this.animation})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.blueAccent.withOpacity(0.7);

    // Calculate the yOffset based on the water level
    final double yOffset = size.height * (1 - waterLevel);

    // Create the water rectangle (below the wave)
    final waterRect = Rect.fromLTWH(0, yOffset, size.width, size.height - yOffset);
    canvas.drawRect(waterRect, paint);

    // Draw the waves
    final wavePath = Path();
    for (double i = 0; i <= size.width; i++) {
      double waveHeight = 8.0 * sin((i / size.width * 2 * pi) + animation.value * 2 * pi);
      wavePath.lineTo(i, yOffset + waveHeight);
    }
    wavePath.lineTo(size.width, size.height);
    wavePath.lineTo(0, size.height);
    wavePath.close();

    canvas.drawPath(wavePath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

//---------------------------------------------------------------------------------------------------------------------------
class ChartDisplay extends StatefulWidget {
  const ChartDisplay({super.key});

  @override
  State<ChartDisplay> createState() => _ChartDisplayState();
}

class _ChartDisplayState extends State<ChartDisplay> {
  @override
  Widget build(BuildContext context) {
    return LineChart(
        LineChartData(
            minX: 0,
            maxX: 6,
            minY: 0,
            maxY: 100,
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 8,// Space for the text
                    getTitlesWidget: (value, meta) {
                      switch (value.toInt()) {
                        case 0:
                          return const Text('Mon');
                        case 1:
                          return const Text('Tue');
                        case 2:
                          return const Text('Wed');
                        case 3:
                          return const Text('Thu');
                        case 4:
                          return const Text('Fri');
                        case 5:
                          return const Text('Sat');
                        case 6:
                          return const Text('Sun');
                        default:
                          return const Text('');
                      }
                    },
                  )
              ),
              rightTitles:AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 8,// Space for the text
                    getTitlesWidget: (value, meta) {
                      switch (value.toInt()) {
                        case 0:
                          return const Text('12');
                        case 1:
                          return const Text('13');
                        case 2:
                          return const Text('14');
                        case 3:
                          return const Text('15');
                        case 4:
                          return const Text('16');
                        case 5:
                          return const Text('17');
                        case 6:
                          return const Text('18');
                        default:
                          return const Text('');
                      }
                    },
                  )
              ),
            ),
            gridData: FlGridData(
              show: true,//if set false no graph grids will be shown
              getDrawingHorizontalLine: (value) {
                return const FlLine(
                  color: Colors.black54,
                  strokeWidth: 1,//thickness of grid line in this case horizontal line
                );
              },
              drawVerticalLine: true,
              getDrawingVerticalLine: (value) {
                return const FlLine(
                  color: Colors.black54,
                  strokeWidth: 1,//thickness of grid line in this case horizontal line
                );
              },
            ),
            borderData: FlBorderData(
              show: true,
              border: const Border(
                right: BorderSide(),
                bottom: BorderSide(),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved:true,
                color: Colors.purple,
                barWidth: 3,
                dotData: FlDotData(
                  show: true, // Show the dots
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4, // Size of the dots
                      color: Colors.blue, // Dot color
                      strokeWidth: 2,
                      strokeColor: Colors.blueAccent, // Optional stroke color
                    );
                  },
                ),
                // belowBarData: BarAreaData(
                //   gradient: LinearGradient(
                //     begin: Alignment.topCenter,
                //     end: Alignment.bottomCenter,
                //     colors: [
                //       Colors.purple.withOpacity(0.5),
                //       Colors.transparent
                //     ],
                //   ),
                //   show: true,
                // ),
              ),
            ]
        )
    );
  }
}
//-------------------------------------
class circularPercentIndicator extends StatelessWidget {
  final double radius;
  final double lineWidth;
  final double percent;
  final Widget center;
  final Color progressColor;
  final Color backgroundColor;

  circularPercentIndicator({
    required this.radius,
    required this.lineWidth,
    required this.percent,
    required this.center,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius,
      height: radius,
      child: Stack(
        children: [
          Center(
            child: SizedBox(
              width: radius,
              height: radius,
              child: CustomPaint(
                painter: CircularProgressPainter(
                  progress: percent,
                  strokeWidth: lineWidth,
                  progressColor: progressColor,
                  backgroundColor: backgroundColor, // Non-progress part in white
                ),
              ),
            ),
          ),
          Center(child: center),
        ],
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color progressColor;
  final Color backgroundColor;

  CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Paint progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round; // Makes the ends of the progress line round

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth / 2);

    // Draw background circle
    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    final double sweepAngle = 2 * 3.14159265359 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159265359 / 2, // Start angle at the top of the circle
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
//---------------------------------------
void showLottieAlertDialog(BuildContext context,String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0), // Curved edges for the dialog
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min, // Wraps content
          children: [
            // Lottie animation
            Lottie.asset(
              'assets/Lottie/done.json', // Add your Lottie file path
              height: 150,
              width: 150,
            ),
            SizedBox(height: 20),
            // Message
            Text(
              message,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), // Rounded button
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
//----------------------------------------------------------------------------------
void showReminderAlertDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0), // Curved edges for the dialog
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min, // Wraps content
          children: [
            // Lottie animation
            Lottie.asset(
              'assets/Lottie/done.json', // Add your Lottie file path
              height: 150,
              width: 150,
            ),
            SizedBox(height: 20),
            // Message
            Text(
              message,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), // Rounded button
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
//------------------------------------------------------------------
void showLottieReminder(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0), // Curved edges for the dialog
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min, // Wraps content
          children: [
            // Lottie animation
            Lottie.asset(
              'assets/Lottie/alarm.json', // Add your Lottie file path
              height: 150,
              width: 150,
            ),
            SizedBox(height: 20),
            // Message
            Text(
              'you set your reminder here',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), // Rounded button
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}