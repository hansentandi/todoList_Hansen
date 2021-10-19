import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'model/task.dart';

class ToDoListDatabase{
  static final ToDoListDatabase instance = ToDoListDatabase._init();

  static Database? _database;

  ToDoListDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('todo.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT NOT NULL';

    await db.execute('''
CREATE TABLE $tableTask ( 
  ${TaskFields.id} $idType, 
  ${TaskFields.title} $textType,
  ${TaskFields.desc} $textType
  )
  ''');
  }

  Future<Task> create(Task task) async {
    final db = await instance.database;
    final id = await db.insert(tableTask, task.toJson());
    return task.copy(id: id);
  }

  Future<Task> readToDo(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableTask,
      columns: TaskFields.values,
      where: '${TaskFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Task.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Task>> readAllToDo() async {
    final db = await instance.database;

    final orderBy = '${TaskFields.id} ASC';
    // final result =
    //     await db.rawQuery('SELECT * FROM $tableToDo ORDER BY $orderBy');

    final result = await db.query(tableTask, orderBy: orderBy);

    return result.map((json) => Task.fromJson(json)).toList();
  }

  Future<int> update(Task task) async {
    final db = await instance.database;

    return db.update(
      tableTask,
      task.toJson(),
      where: '${TaskFields.id} = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableTask,
      where: '${TaskFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}