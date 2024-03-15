import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:running_log/services_and_helpers/User.dart';
import 'package:sqflite/sqflite.dart';

class UserDatabase {
  UserDatabase._();
  static final UserDatabase instance = UserDatabase._();
  static Database? _database;

  Future<Database> get database async => _database ??= await initDatabase();

  initDatabase () async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'user.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE user (
            name TEXT,
            age INTEGER,
            height REAL,
            weight INTEGER,
            types TEXT,
            colors TEXT
          )
      ''');
      },
    );
  }

  Future<List<User>> getUser () async {
    Database db = await instance.database;
    var user = await db.query('user');
    List<User> userList = user.isNotEmpty ? user.map((u) => User.fromMap(u)).toList() : [];
    return userList;
  }

  Future<int> addUser (User user) async {
    Database db = await instance.database;
    return await db.insert('user', user.toMap());
  }

  Future<int> updateUser (User user) async {
    Database db = await instance.database;
    return await db.update('user', user.toMap(), where: '_id = ?', whereArgs: [1]);
  }

  Future<void> clearDatabase () async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'user.db');
    databaseFactory.deleteDatabase(path);
  }
}