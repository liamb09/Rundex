import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:running_log/services_and_helpers/Run.dart';
import 'package:sqflite/sqflite.dart';

class RunsDatabase {
  RunsDatabase._();
  static final RunsDatabase instance = RunsDatabase._();
  static Database? _database;

  Future<Database> get database async => _database ??= await initDatabase();

  initDatabase () async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'runs.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE runs (
            _id INTEGER PRIMARY KEY AUTOINCREMENT, 
            title TEXT, 
            distance REAL, 
            unit TEXT, 
            time INTEGER, 
            perceivedEffort REAL,
            type TEXT, 
            notes TEXT,
            sets BLOB,
            color TEXT,
            timestamp INTEGER,
            image BLOB
          )
      ''');
      },
    );
  }

  Future<List<Run>> getRuns () async {
    Database db = await instance.database;
    var runs = await db.query('runs', orderBy: "timestamp DESC");
    List<Run> runsList = runs.isNotEmpty ? runs.map((r) => Run.fromMap(r)).toList() : [];
    return runsList;
  }

  Future<int> addRun (Run run) async {
    Database db = await instance.database;
    return await db.insert('runs', run.toMap());
  }

  Future<int> removeRun (int id) async {
    Database db = await instance.database;
    return await db.delete('runs', where: '_id = ?', whereArgs: [id]);
  }

  Future<int> updateRun (Run run) async {
    Database db = await instance.database;
    return await db.update('runs', run.toMap(), where: '_id = ?', whereArgs: [run.id]);
  }

  Future<void> clearDatabase () async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'runs.db');
    databaseFactory.deleteDatabase(path);
  }
}