import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/task_model.dart';
import 'database_config_stub.dart'
    if (dart.library.io) 'database_config_io.dart';

class TaskRepository {
  static final TaskRepository _instance = TaskRepository._internal();
  static Database? _database;

  factory TaskRepository() {
    return _instance;
  }

  TaskRepository._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    if (kIsWeb) {
      throw UnsupportedError(
        'O sqflite nao funciona no Flutter Web. Rode o app em Windows, '
        'Android ou iOS para usar SQLite local.',
      );
    }

    await configureDatabaseFactory();

    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'lista_tarefas.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            isDone INTEGER NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insertTask(TaskModel task) async {
    final db = await database;
    return db.insert('tasks', task.toMap());
  }

  Future<List<TaskModel>> getAllTasks() async {
    final db = await database;
    final result = await db.query('tasks', orderBy: 'id DESC');

    return result.map(TaskModel.fromMap).toList();
  }

  Future<TaskModel?> getTaskById(int id) async {
    final db = await database;
    final result = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return TaskModel.fromMap(result.first);
  }

  Future<int> updateTask(TaskModel task) async {
    final db = await database;
    return db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
