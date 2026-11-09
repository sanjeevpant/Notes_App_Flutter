import 'dart:ffi';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  //Singleton Private constructor
  DbHelper._();
  static DbHelper getInstance() => DbHelper._();
  static const String dbName = "notesDB.db";
  static const String tableNote = "note";
  static const String columnNoteId = "note_id";
  static const String columnNoteTitle = "note_title";
  static const String columnNoteDesc = "note_desc";
  static const String columnNoteCreatedAt = "note_created_at";

  Database? mdb;

  Future<Database> initDB() async {
    mdb ??= await openDb();
    return mdb!;
  }

  Future<Database> openDb() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbPath = join(appDir.path, dbName);
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) {
        db.execute(
          "create table $tableNote ( $columnNoteId integer primary key autoincrement, $columnNoteTitle text, $columnNoteDesc text, $columnNoteCreatedAt text)",
        );
      },
    );
  }

  // Add Note
  Future<bool> addNote({required String title, required String desc}) async {
    Database db = await initDB();
    int rowsEffected = await db.insert(tableNote, {
      columnNoteTitle: title,
      columnNoteDesc: desc,
      columnNoteCreatedAt: DateTime.now().millisecondsSinceEpoch.toString(),
    });

    return rowsEffected > 0;
  }

  // fetch Note
  Future<List<Map<String, dynamic>>> getAllNotes() async {
    Database db = await initDB();
    return await db.query(tableNote);
  }

  // update Note
  Future<bool> updateNote({required String updateTitle, required String updateDesc, required int id}) async {
    Database db = await initDB();
    int rowsEffected = await db.update(tableNote, {
      columnNoteTitle: updateTitle,
      columnNoteDesc: updateDesc
    }, where: "$columnNoteId = ?", whereArgs: ["$id"]);

    return rowsEffected>0;
  }

  // delete Note
  Future<bool> deleteNote({required int id}) async {
    Database db = await initDB();
    return await db.delete(tableNote, where: "$columnNoteId = ?", whereArgs: ["$id"]) > 0;
  }
}
