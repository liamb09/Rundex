import 'package:path/path.dart';
import 'package:running_log/Run.dart';
import 'package:sqflite/sqflite.dart';

class RunsDatabase {
  static final RunsDatabase instance = RunsDatabase._init();

  static Database? _database;

  RunsDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("runs.db");
    return _database!;
  }

  Future<Database> _initDB (String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _creatDB);
  }

  Future _creatDB (Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableNotes (
        ${RunFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${RunFields.title} TEXT,
        ${RunFields.distance} REAL,
        ${RunFields.unit} TEXT,
        ${RunFields.time} INTEGER,
        ${RunFields.type} TEXT,
        ${RunFields.notes} TEXT
      )
    ''');
  }

  Future<Run> create (Run run) async {
    final db = await instance.database;
    final id = await db.insert(tableNotes, run.toMap());
    return run.copy(id: id);
  }

  Future<Run> readRun (int id) async {
    final db = await instance.database;
    final maps = await db.query(
      tableNotes,
      columns: RunFields.values,
      where: '${RunFields.id} = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Run.fromMap(maps.first);
    } else {
      throw Exception("ID $id not found");
    }
  }

  Future<List<Run>> readAllRuns () async {
    final db = await instance.database;
    final result = await db.query(tableNotes);
    return result.map((map) => Run.fromMap(map)).toList();
  }

  Future<int> update (Run run) async {
    final db = await instance.database;
    return db.update(
      tableNotes,
      run.toMap(),
      where: "${RunFields.id} = ?",
      whereArgs: [run.id],
    );
  }

  Future<int> delete (int id) async {
    final db = await instance.database;
    return await db.delete(
      tableNotes,
      where: "${RunFields.id} = ?",
      whereArgs: [id],
    );
  }

  Future close () async {
    final db = await instance.database;
    db.close();
  }
}