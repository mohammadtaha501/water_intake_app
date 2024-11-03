import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';

class UnableToGetDocumentsDirectory implements Exception{}
class DataNotAdded implements Exception{}
class RecordNotFound implements Exception {
  final String message;

  RecordNotFound([this.message = "No matching record found."]);

  @override
  String toString() => message;
}

class datastorage{
  Database? _db;

  static final _instance = datastorage._sharedInstance();
  datastorage._sharedInstance();
  factory datastorage()=> _instance;

  Future<void> open()async{
    if (_db != null) return;

    try {
      print("in open");
      final docsPath=await getApplicationDocumentsDirectory();
      final dbPath=join(docsPath.path,"water_intake.db");
      _db = await openDatabase(dbPath);
      await _db?.execute('''
      CREATE TABLE IF NOT EXISTS water_intake (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT NOT NULL,
      time TEXT NOT NULL,
      amount_ml INTEGER NOT NULL,
      cumulative_total_ml INTEGER
    )
    ''');
    }on MissingPlatformDirectoryException {
      print("in open exception");
      throw UnableToGetDocumentsDirectory();
    }
  }

  Future<List<Map<String, dynamic>>> getWaterIntakeByDate(String date) async {
    if (_db == null) {
      await open(); // Ensure the database is opened
    }

    List<Map<String, dynamic>> results = await _db!.query(
        'water_intake', // Table name
        columns: ['time', 'amount_ml'], // The columns you want to retrieve
        where: 'date = ?', // WHERE clause to match the date
        whereArgs: [date], // Arguments for the WHERE clause
        orderBy: 'id ASC'
    );

    return results; // Return the list of results
  }

  Future<int> getMonthlyCumulativeTotal(String monthStartDate) async {
    if (_db == null) {
      throw Exception("Database is not open");
    }

    // Parse the monthStartDate to get the start and end dates of the month
    DateTime startDate = DateTime.parse(monthStartDate);
    DateTime endDate = DateTime(startDate.year, startDate.month + 1, 1).subtract(Duration(days: 1));

    // Query to get the last cumulative_total_ml for each day of the month using max(id) for each date
    final List<Map<String, dynamic>> result = await _db!.rawQuery('''
    SELECT cumulative_total_ml
    FROM water_intake AS w
    WHERE date BETWEEN ? AND ?
    AND id = (SELECT MAX(id) FROM water_intake WHERE date = w.date)
  ''', [monthStartDate, endDate.toIso8601String()]);

    // Sum the cumulative_total_ml for each day
    int totalCumulative = result.fold(0, (sum, row) => sum + (row['cumulative_total_ml'] as int? ?? 0));

    return totalCumulative;
  }


  Future<List<double>> reportWeekProcessing(DateTime startDate,int addTilDays) async {
    List<double> cumulativeTotals = [];
    for(int i = 0 ;i <= addTilDays ;i++ ){
      final date = startDate.add(Duration(days:i));
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final result = await getLastCumulativeTotal(formattedDate);
      if (result==null) {
        cumulativeTotals.add(0);
      } else {
        cumulativeTotals.add(result.toDouble());
      }
    }
    return cumulativeTotals;
  }

  Future<List<int>> getCumulativeTotalForNextSevenDays(DateTime startDate) async {
    // List to store cumulative totals for each day
    List<int> cumulativeTotals = [];

    try {if (_db == null) {
      await open();
       }
      for (int i = 0; i < 7; i++) {
        // Calculate the date for each day (starting from startDate)
        final date = startDate.add(Duration(days:i));
        final formattedDate = DateFormat('yyyy-MM-dd').format(date);

        final result = await getLastCumulativeTotal(formattedDate);

        if (result==null) {
          cumulativeTotals.add(0);
        } else {
          cumulativeTotals.add(result);
        }
      }
    } catch (e) {
      print('Error fetching cumulative totals: $e');
      throw Exception("Error fetching cumulative totals");
    }

    return cumulativeTotals; // Return the list of totals for the 7 days
  }


  Future<int?> getLastCumulativeTotal(String date) async {
    if (_db == null) {
      await open();
    }
    List<Map<String, dynamic>> results = await _db!.rawQuery(
        'SELECT cumulative_total_ml FROM water_intake WHERE date = ? ORDER BY id DESC LIMIT 1',
        [date]
    );

    if (results.isNotEmpty) {
      return results.first['cumulative_total_ml'] as int;
    }
    return null;
  }

    Future<void> addWaterIntake( String date, String time, int amountMl) async {
      if (_db == null) {
        await open();
      }
      final int? cumulativeTotalMl =await getLastCumulativeTotal(date) ;
      Map<String, dynamic> data = {
        'date': date,
        'time': time,
        'amount_ml': amountMl,
        'cumulative_total_ml': cumulativeTotalMl != null ? amountMl + cumulativeTotalMl : amountMl,
      };
  
      int id = await _db!.insert('water_intake', data);
      if(id == -1){
        throw DataNotAdded();
      }
    }

  Future<void> deleteWaterIntake(String date, String time) async {
    if (_db == null) {
      throw Exception("Database is not open");
    }
    final int result = await _db!.delete(
      'water_intake',
      where: 'date = ? AND time = ?',
      whereArgs: [date, time],
    );

    if (result == 0) {
      throw RecordNotFound();
    }
    // this is how to catch this exception in main code
    // try {
    //   await deleteWaterIntake('2024-10-08', '14:30:00');
    //   print('Record deleted successfully!');
    // } on RecordNotFound catch (e) {  // Catching the specific exception and naming it 'e'
    //   print('Error: ${e.message}');
    // } catch (e) {  // Catching any other exceptions
    //   print('An unexpected error occurred: $e');
    // }
  }

  Future<List<Map<String, dynamic>>> getAllWaterIntakeRecords() async {
    if (_db == null) {
      throw Exception("Database is not open");
    }
    List<Map<String, dynamic>> results = await _db!.query('water_intake');
    return results;
  }

}

final waterDataService = datastorage();