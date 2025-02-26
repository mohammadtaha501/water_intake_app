import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../databaseStorage.dart';
import 'customizeReport.dart';
import 'settingScreen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  bool _isVisible = false;
  List<double> weeklyYvalues = [];
  double maxWeeklyY =0;
  double weaklyIntervals=0;
  double maxMonthlyY =0;
  double monthlyIntervals=0;
  List<double> monthlyYvalues = [];

  Future<void> processDataForWeek() async {
    // print('weaklyIntervals:$weaklyIntervals');
    DateTime weekStartDate = _focusedDay.subtract(Duration(days: _focusedDay.weekday - 1));
    List<int> weeklyValuesDouble =await waterDataService.getCumulativeTotalForNextSevenDays(weekStartDate);
    weeklyYvalues = weeklyValuesDouble.map((value) => value.toDouble()).toList();
    maxWeeklyY = (weeklyYvalues.isNotEmpty ? weeklyYvalues.reduce((a, b) => a > b ? a : b) : 0) * 1.2 ;
    weaklyIntervals = (maxWeeklyY/4).floor().toDouble();
    // print("weeakly");
  }
  Future<void> processDataForMonth() async {
    DateTime monthStartDate = _focusedDay.subtract(Duration(days: _focusedDay.day - 1));
    for(int i=0;i<4;i++){
      final a=i*7;
      monthStartDate = monthStartDate.add(Duration(days:a));
      List<int> weeklyValuesDouble =await waterDataService.getCumulativeTotalForNextSevenDays(monthStartDate);
      int greatestValue = weeklyValuesDouble.reduce((a, b) => a + b);
      monthlyYvalues.add(greatestValue.toDouble());
    }
    maxMonthlyY = (monthlyYvalues.isNotEmpty ? monthlyYvalues.reduce((a, b) => a > b ? a : b) : 0) * 1.2 ;
    monthlyIntervals = (maxMonthlyY/4).floor().toDouble();
  }
  Future<void> _initializeData() async {
    // print("_initializeData");
    await processDataForWeek();
    // print("_initializeData2");
    await processDataForMonth();
    setState(() { });
  }

  @override
  void initState() {
    super.initState();
    // print("initstate");
    _initializeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.lerp(Colors.lightBlueAccent, Colors.white, 0.3)!,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text('History',),
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen(),));
              },
              icon: const Icon(Icons.settings)
          ),
        ],
      ),
      body: ListView(
        children:[
          Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: GestureDetector(
                  child: Container(
                    height:40,
                    width: 340.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:BorderRadius.circular(20),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 10.0,right: 4.0),
                          child: Icon(Icons.calendar_month_outlined,color: Colors.blueAccent,),
                        ),
                        const Text("Calender"),
                        const SizedBox(width: 180,),
                        Visibility(
                          visible: !_isVisible,
                          replacement: const Padding(
                            padding: EdgeInsets.only(left: 14.0),
                            child: Icon(Icons.arrow_drop_up,),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.only(left: 14.0),
                            child: Icon(Icons.arrow_drop_down,),
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    setState(() {
                    _isVisible = !_isVisible;
                      });
                    },
                ),
              ),
            ),

            Visibility(
              visible: _isVisible,
              child: AnimatedSwitcher(
                duration: const Duration(seconds: 1),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Center(
                    child: Container(
                      height: 370,
                      width: 340,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child:TableCalendar(
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.now(),
                          focusedDay: _focusedDay,
                          rowHeight: 45,
                          sixWeekMonthsEnforced: true,
                          startingDayOfWeek: StartingDayOfWeek.monday,
                          rangeStartDay: _rangeStart,
                          rangeEndDay: _rangeEnd,
                          rangeSelectionMode: RangeSelectionMode.toggledOn,
                          onRangeSelected: (start, end, focusedDay) {
                              _selectedDay = null;
                              _focusedDay = focusedDay;
                              _rangeEnd = end;
                              _rangeStart = start;
                              if (end!=null&&start!=null) {
                                if (end.isBefore(start)) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => CustomizeReport(end: start, start: end,),)
                                  );
                                } else {
                                  if (start != end) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder:(context) => CustomizeReport(end: end, start: start,), )
                                    );
                                  }
                                }
                              }
                              setState(() {});
                          },
                          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                          },

                          headerStyle: const HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            titleTextStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),

                          daysOfWeekHeight: 20,
                          daysOfWeekStyle: DaysOfWeekStyle(
                            weekdayStyle: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 10), // Adjust font size
                            weekendStyle: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 10), // Adjust font size
                          ),

                          calendarStyle: CalendarStyle(
                            cellMargin: const EdgeInsets.only(top: 0,right: 2,left: 2),
                            selectedDecoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            todayDecoration: const BoxDecoration(),
                            todayTextStyle: const TextStyle(color: Colors.black),
                            rangeStartDecoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            rangeEndDecoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            rangeHighlightColor: Colors.lightBlueAccent.withOpacity(0.2),

                            //outsideDaysVisible: false, //to not to add the days of the other month at the starting and end of the month

                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(top: 18.0,left: 30,bottom: 18),
              child: Text(
                "Weekly Statistics",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 8.0,),
              child: Center(
                child: Container(
                  height: 220,
                  width: 340,
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
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(top: 18.0,left: 30,bottom: 18),
              child: Text(
                "Monthly Statistics",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),

            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 28.0),
                child: Container(
                  height: 220,
                  width: 340,
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
                                switch (value.toInt()) {
                                  case 0:
                                    return const Text('week1');
                                  case 1:
                                    return const Text('week2');
                                  case 2:
                                    return const Text('week3');
                                  case 3:
                                    return const Text('week4');
                                  default:
                                    return const Text('');
                                }
                              },
                              reservedSize: 28, // Space for bottom titles
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
                                if (value == maxMonthlyY && maxMonthlyY != 0) { // Show 'ml' at the top
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
                ),
              ),
            ),

          ],
        ),
        ]
      ),
    );
  }
}
