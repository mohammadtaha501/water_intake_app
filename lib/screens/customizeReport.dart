import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../databaseStorage.dart';

class CustomizeReport extends StatefulWidget {
  final DateTime start;
  final DateTime end;
  const CustomizeReport({super.key, required this.start, required this.end});

  @override
  State<CustomizeReport> createState() => _CustomizeReportState();
}

class _CustomizeReportState extends State<CustomizeReport> {
  bool isWeekly=true;
  double maxWeeklyY =0;
  double maxMonthlyY =0;
  double weaklyIntervals=0;
  double monthlyIntervals=0;
  List<bool> isSelected = [true, false];
  List<String> monthNames = [];
  List<double> weeklyYvalues = [];
  List<double> monthlyYvalues = [];

  @override
  void initState() {
    super.initState();
    _initilize();
  }

  Future<void> _initilize()async{
    await weeklyReportProcessing();
    monthNamesCalculator();
    await monthlyReportCalculation();
    setState(() {});
  }

  Future<void> monthlyReportCalculation() async {
    int difference = (widget.end.year - widget.start.year) * 12 + (widget.end.month - widget.start.month);
    for(int i = 0 ;i <= difference ;i++ ){
      DateTime nextMonth = DateTime(widget.start.year, widget.start.month + i, 1);
      if (nextMonth.month == 1 && i != 0) {
        nextMonth = DateTime(nextMonth.year + 1, 1, 1);
      }
      String startDate = DateFormat('yyyy-MM-dd').format(nextMonth);
      int cumulative = await waterDataService.getMonthlyCumulativeTotal(startDate);
      monthlyYvalues.add(cumulative.toDouble());
    }
    maxMonthlyY = (monthlyYvalues.isNotEmpty ? monthlyYvalues.reduce((a, b) => a > b ? a : b) : 0) * 1.2 ;
    monthlyIntervals = (maxMonthlyY/4).floor().toDouble();
    setState(() {});
  }

  void monthNamesCalculator(){
    int difference = widget.end.month - widget.start.month;
    for (int i = 0; i <= difference; i++) {
      DateTime month = DateTime(widget.start.year, widget.start.month + i);
      String monthName = DateFormat.MMMM().format(month); // Get month name
      monthNames.add(monthName); // Add month name to list
    }
    setState(() {});
  }

  Future<void> weeklyReportProcessing() async {
    weeklyYvalues.addAll(List.filled((widget.start.weekday-1), 0));
    int differenceFromDate = widget.end.difference(widget.start).inDays;
    int difference = 7 - widget.start.weekday ;
    if(differenceFromDate<difference){
      List<double> weeklyValuesDouble =await waterDataService.reportWeekProcessing(widget.start,differenceFromDate);
      weeklyYvalues.addAll(weeklyValuesDouble);
      while (weeklyYvalues.length < 7) {
        weeklyYvalues.add(0);
      }
    }else{
      List<double> weeklyValuesDouble =await waterDataService.reportWeekProcessing(widget.start,difference);
      weeklyYvalues.addAll(weeklyValuesDouble);
    }
    maxWeeklyY = (weeklyYvalues.isNotEmpty ? weeklyYvalues.reduce((a, b) => a > b ? a : b) : 0) * 1.2 ;
    weaklyIntervals = (maxWeeklyY/4).floor().toDouble();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.lerp(Colors.lightBlueAccent, Colors.white, 0.3)!,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Center(child: Text("Statistics"),),
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Icons.settings))
          ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Visibility(
            visible: isWeekly,
            replacement:Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Text("Monthly Report",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Text("Weekly Report",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
            ),
          ),

          SizedBox(
            height: 40,
            child: ToggleButtons(
              renderBorder: false,
              borderRadius: BorderRadius.circular(25),
              fillColor: Colors.blue, // Background color when selected
              selectedColor: Colors.black, // Text color when selected
              color: Colors.black, // Text color for unselected buttons
              constraints: BoxConstraints(
                minHeight: 40, // Set the minimum height
                minWidth: 100, // Set the minimum width
              ),
              onPressed: (int index) {
                setState(() {
                  if(index==0){isWeekly=true;}
                  else{isWeekly=false;}
                  for (int i = 0; i < isSelected.length; i++) {
                    isSelected[i] = i == index;
                  }
                }
                );
              },
              isSelected: isSelected,
              children: [
                Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: isSelected[0] ? Colors.transparent : Colors.white,
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15,right: 15),
                    child: Text(
                      'Weekly',
                    ),
                  ),
                ),
                Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: isSelected[1] ? Colors.transparent : Colors.white,
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 13,right: 15),
                    child: Text(
                      'Monthly',
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 55, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.arrow_back_ios_outlined),
                Text(
                  '${DateFormat('yyyy-MM-dd').format(widget.start)} - ${DateFormat('yyyy-MM-dd').format(widget.start)}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(Icons.arrow_forward_ios_outlined),
              ],
            ),
          ),

          Visibility(
            visible: isWeekly,
            replacement: MonthlyChart(
              monthNames: monthNames,
              monthlyYvalues: monthlyYvalues,
              monthlyIntervals: monthlyIntervals,
              maxMonthlyY: maxMonthlyY,
            ),
            child: WeeklyChart(
              weeklyYvalues: weeklyYvalues,
              maxWeeklyY: maxWeeklyY,
              weaklyIntervals: weaklyIntervals,
            ),
          )
        ],
      ),
    );
  }
}

class WeeklyChart extends StatelessWidget {
  WeeklyChart({super.key,required this.weeklyYvalues,required this.maxWeeklyY,required this.weaklyIntervals});

  final List<double> weeklyYvalues;
  final maxWeeklyY;
  final weaklyIntervals;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 340,
      width: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 14.0,bottom: 14.0,top: 20,right: 10),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround, // Aligns bars evenly spaced
            maxY:maxWeeklyY==0?10:maxWeeklyY, // Maximum Y-axis value
            minY: 0, // Minimum Y-axis value (optional)
            barTouchData: BarTouchData(
              enabled: true, // Enables touch interactions
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    rod.toY.toString(), // Tooltip text
                    const TextStyle(
                      color: Colors.white, // Tooltip text color
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    switch (value.toInt()) {
                      case 0:
                        return const Text('M');
                      case 1:
                        return const Text('T');
                      case 2:
                        return const Text('W');
                      case 3:
                        return const Text('T');
                      case 4:
                        return const Text('F');
                      case 5:
                        return const Text('S');
                      case 6:
                        return const Text('S');
                      default:
                        return const Text('');
                    }
                  },
                  reservedSize: 20, // Space for bottom titles
                ),
              ),
              rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false,)
              ),
              topTitles: const AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,)
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: weaklyIntervals==0?2:weaklyIntervals,
                  getTitlesWidget: (value, meta) {
                    if (value == maxWeeklyY && maxWeeklyY != 0) { // Show 'ml' at the top
                      return Text(
                        "ml",
                        style: TextStyle(color: Colors.black.withOpacity(0.5)),
                      );
                    } else if (value % weaklyIntervals == 0 && weaklyIntervals != 0) { // Show values at multiples of 100
                      return Text(
                        value.toInt().toString(),
                      );
                    }else if(maxWeeklyY == 0 && value % 1== 0){
                      return Text(
                        value.toInt().toString(),
                      );
                    }
                    return const SizedBox.shrink(); // Hide other labels
                  },
                  reservedSize: 48, // Space for left titles
                ),
              ),
            ),
            gridData: FlGridData(
              show: true, // Show grid lines
              drawHorizontalLine: true,
              getDrawingHorizontalLine: (value) {
                return const FlLine(
                  color: Colors.grey, // Grid line color
                  strokeWidth: 0.5, // Grid line thickness
                );
              },
              drawVerticalLine: false,
              // getDrawingVerticalLine: (value) {
              //   return const FlLine(
              //     color: Colors.black, // Vertical grid line color
              //     strokeWidth: 1, // Vertical grid line thickness
              //   );
              // },
            ),
            borderData: FlBorderData(
              show: true,
              border: const Border(
                left: BorderSide.none,
                bottom: BorderSide(
                  color: Colors.black, // Bottom border color
                  width: 0.5, // Bottom border width
                ),
                right: BorderSide.none, // No border on the right
                top: BorderSide.none, // No border on the top
              ),
            ),
            barGroups:List.generate( //barData
              weeklyYvalues.length, // Number of bars/groups to create
                  (index) => BarChartGroupData(
                x: index, // X-axis value (corresponding to the day index)
                barRods: [
                  BarChartRodData(
                    toY: weeklyYvalues[index] , // Y-axis value from the list
                    color: Colors.lightBlueAccent, // Bar color from the list
                    width: 10, // Set the bar width
                    borderRadius: BorderRadius.circular(4), // Set the rounded corners for bars
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MonthlyChart extends StatelessWidget {
  final List<double> monthlyYvalues;
  final List<String> monthNames;
  final maxMonthlyY;
  final monthlyIntervals;
  const MonthlyChart({super.key, required this.monthlyYvalues, required this.monthNames,required this.monthlyIntervals, this.maxMonthlyY});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 340,
      width: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 14.0,bottom: 14.0,top: 20,right: 10),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround, // Aligns bars evenly spaced
            maxY: maxMonthlyY==0?10:maxMonthlyY, // Maximum Y-axis value
            minY: 0, // Minimum Y-axis value (optional)
            barTouchData: BarTouchData(
              enabled: true, // Enables touch interactions
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    rod.toY.toString(), // Tooltip text
                    const TextStyle(
                      color: Colors.white, // Tooltip text color
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 && value.toInt() < monthNames.length) {
                      return Text(monthNames[value.toInt()]);
                    } else {
                      return const Text('');
                    }
                  },
                  reservedSize: 20, // Space for bottom titles
                ),
              ),
              rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false,)
              ),
              topTitles: const AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,)
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: monthlyIntervals==0?2:monthlyIntervals,
                  getTitlesWidget: (value, meta) {
                    if (value == maxMonthlyY && maxMonthlyY != 0) {
                      return Text(
                        "ml",
                        style: TextStyle(color: Colors.black.withOpacity(0.5)),
                      );
                    } else if (value % monthlyIntervals== 0&&monthlyIntervals!=0) { // Show values at multiples of 100
                      return Text(
                        value.toInt().toString(),
                      );
                    }else if(maxMonthlyY == 0 && value % 1== 0){
                      return Text(
                        value.toInt().toString(),
                      );
                    }
                    return const SizedBox.shrink(); // Hide other labels
                  },
                  reservedSize: 49, // Space for left titles
                ),
              ),
            ),
            gridData: FlGridData(
              show: true, // Show grid lines
              drawHorizontalLine: true,
              getDrawingHorizontalLine: (value) {
                return const FlLine(
                  color: Colors.grey, // Grid line color
                  strokeWidth: 0.5, // Grid line thickness
                );
              },
              drawVerticalLine: false,
              // getDrawingVerticalLine: (value) {
              //   return const FlLine(
              //     color: Colors.black, // Vertical grid line color
              //     strokeWidth: 1, // Vertical grid line thickness
              //   );
              // },
            ),
            borderData: FlBorderData(
              show: true,
              border: const Border(
                left: BorderSide.none,
                bottom: BorderSide(
                  color: Colors.black, // Bottom border color
                  width: 0.5, // Bottom border width
                ),
                right: BorderSide.none, // No border on the right
                top: BorderSide.none, // No border on the top
              ),
            ),
            barGroups:List.generate( //barData
              monthlyYvalues.length, // Number of bars/groups to create
                  (index) => BarChartGroupData(
                x: index, // X-axis value (corresponding to the day index)
                barRods: [
                  BarChartRodData(
                    toY: monthlyYvalues[index] , // Y-axis value from the list
                    color: Colors.lightBlueAccent, // Bar color from the list
                    width: 10, // Set the bar width
                    borderRadius: BorderRadius.circular(4), // Set the rounded corners for bars
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
