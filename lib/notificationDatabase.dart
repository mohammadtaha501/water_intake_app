import 'package:sqflite/sqflite.dart';
import "package:path/path.dart" show join;
import "package:path_provider/path_provider.dart";

class UnableToGetDocumentsDirectory implements Exception{}

class NoticeData{

  Database? _db;
  static final _instance = NoticeData._sharedinstance();
  NoticeData._sharedinstance();
  factory NoticeData(){
    return _instance;
  }

  Future<void> open() async {

    if (_db != null) return;

    try{
      final path = join(await getDatabasesPath(), 'my_database.db');
      _db = await openDatabase(
        path,
        version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('''
        CREATE TABLE IF NOT EXISTS myTable (
        set_id INTEGER NOT NULL,
        notice_id INTEGER PRIMARY KEY,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        interval_duration INTEGER NOT NULL,
        volume INTEGER NOT NULL,
        repeat_days TEXT NOT NULL,
        delete_date TEXT NULL
      )
      ''');
        },
      );
    }on MissingPlatformDirectoryException {
      // print("in open exception");
      throw UnableToGetDocumentsDirectory();
    }
  }

  Future<int> insertNotice({required int setId,
    required int noticeId,
    required int startTime,
    required int endTime,
    required int intervalDuration,
    required String repeat,
    required int volume
  }) async {

    if (_db == null) {
      await open();
    }

    return await _db!.insert('myTable', {
      'set_id': setId,
      'notice_id': noticeId,
      'start_time': startTime,
      'end_time': endTime,
      'interval_duration': intervalDuration,
      'repeat_days':repeat,
      'volume':volume,
    });
  }

  Future<bool> doesDataExist() async {
    if (_db == null) {
      await open(); // Ensure the database is open before querying
    }

    // Query the database to count the number of rows in 'myTable'
    final List<Map<String, dynamic>> result = await _db!.rawQuery('SELECT COUNT(*) AS count FROM myTable');

    // If the result is not empty and the count is greater than zero, return true
    int count = Sqflite.firstIntValue(result) ?? 0;

    return count > 0;
  }


  Future<List<int>> getNoticeIdsBySetId(int setId) async {
    if (_db == null) {
      await open();
    }

    // Query to get all notice_id where set_id matches the input
    final List<Map<String, dynamic>> result = await _db!.query(
      'myTable',
      columns: ['notice_id'],
      where: 'set_id = ?',
      whereArgs: [setId],
    );

    // Extract the notice_id values from the result
    return result.map((row) => row['notice_id'] as int).toList();
  }

  Future<void> deleteNoticesBySetId(int setId) async {
    if (_db == null) {
      await open();
    }

    // Delete all rows with the specified set_id
    await _db!.delete(
      'myTable',
      where: 'set_id = ?',
      whereArgs: [setId],
    );
  }


  Future<List<Map<String, dynamic>>> getUniqueSetIds() async {
    if (_db == null) {
      await open();
    }
    // Get distinct set_ids
    final List<Map<String, dynamic>> uniqueSetIds = await _db!.rawQuery(
        'SELECT DISTINCT set_id FROM myTable'
    );

    // Prepare a list to store the unique rows
    List<Map<String, dynamic>> uniqueRows = [];

    // For each unique set_id, retrieve the first row with that set_id
    for (var row in uniqueSetIds) {
      int setId = row['set_id'] as int;
      // Get the first row with the current set_id
      final List<Map<String, dynamic>> firstRowWithSetId = await _db!.query(
        'myTable',
        where: 'set_id = ?',
        whereArgs: [setId],
        limit: 1,
      );
      // Add the row to the result list
      if (firstRowWithSetId.isNotEmpty) {
        uniqueRows.add(firstRowWithSetId.first);
      }
    }
    return uniqueRows;
  }


  Future<int> getLastNoticeId() async {
    if (_db == null) {
      await open(); // Ensure the database is open
    }

    // Query to get the last notice_id
    final List<Map<String, dynamic>> result = await _db!.query(
      'myTable',
      columns: ['notice_id'],
      orderBy: 'notice_id DESC',  // Order by notice_id in descending order
      limit: 1,                   // Only retrieve the last row
    );

    // If there is data, return the last notice_id, otherwise return 0
    if (result.isNotEmpty) {
      return result.first['notice_id'] as int;
    } else {
      return 0; // Return 0 if there are no rows in the table
    }
  }

  Future<int> getLastSetId() async {
    if (_db == null) {
      await open(); // Ensure the database is open
    }

    try {
      // Query to get the last set_id based on the ROWID
      final List<Map<String, dynamic>> result = await _db!.rawQuery(
          'SELECT set_id FROM myTable ORDER BY ROWID DESC LIMIT 1'
      );

      if (result.isNotEmpty) {
        return result.first['set_id'] as int; // Return the set_id of the last row
      } else {
        return 0; // Return 0 if there are no rows in the table
      }
    } catch (e) {
      throw Exception("Something went wrong while retrieving the last set_id: $e");
    }
  }

}

final noticeData = NoticeData();