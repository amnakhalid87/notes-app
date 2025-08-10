import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  DBHelper._();
  static final String Table_Notes = "Notes";
  static final String Table_Col_1 = "id";
  static final String Table_Col_2 = "name";
  static final String Table_Col_3 = "description";
  static final String Table_Col_4 = "category";

  static final DBHelper getInstance = DBHelper._();
  Database? myDB;

  Future<Database> getDB() async {
    try {
      if (myDB != null) {
        return myDB!;
      } else {
        myDB = await openDB();
        return myDB!;
      }
    } catch (e) {
      print("Error getting database: $e");
      throw Exception("Failed to initialize database: $e");
    }
  }

  Future<bool> isDatabaseReady() async {
    try {
      var db = await getDB();
      // Try to perform a simple query
      await db.rawQuery('SELECT 1');
      return true;
    } catch (e) {
      print("Database not ready: $e");
      return false;
    }
  }

  Future<Database> openDB() async {
    try {
      Directory appDir;

      try {
        appDir = await getApplicationSupportDirectory();
      } catch (e) {
        print(
          "getApplicationSupportDirectory failed, trying getApplicationDocumentsDirectory: $e",
        );
        try {
          appDir = await getApplicationDocumentsDirectory();
        } catch (e2) {
          print(
            "getApplicationDocumentsDirectory failed, using getDatabasesPath: $e2",
          );
          String databasesPath = await getDatabasesPath();
          appDir = Directory(databasesPath);
        }
      }

      if (!await appDir.exists()) {
        await appDir.create(recursive: true);
        print("Created directory: ${appDir.path}");
      }

      String dbPath = join(appDir.path, "notesDB.db");
      print("Database path: $dbPath");

      return await openDatabase(
        dbPath,
        version: 1,
        onCreate: (db, version) async {
          try {
            await db.execute(
              "CREATE TABLE $Table_Notes ("
              "$Table_Col_1 INTEGER PRIMARY KEY AUTOINCREMENT, "
              "$Table_Col_2 TEXT NOT NULL, "
              "$Table_Col_3 TEXT NOT NULL, "
              "$Table_Col_4 TEXT NOT NULL"
              ")",
            );
            print("Database table created successfully");
          } catch (e) {
            print("Error creating table: $e");
            throw Exception("Failed to create database table: $e");
          }
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          print("Database upgraded from version $oldVersion to $newVersion");
        },
        onOpen: (db) {
          print("Database opened successfully");
        },
      );
    } catch (e) {
      print("Error opening database: $e");
      throw Exception("Failed to open database: $e");
    }
  }

  Future<bool> addNotes({
    required String title,
    required String desc,
    required String category,
  }) async {
    try {
      if (title.trim().isEmpty ||
          desc.trim().isEmpty ||
          category.trim().isEmpty) {
        print("Invalid input data");
        return false;
      }

      var db = await getDB();

      int rowsEffected = await db.insert(Table_Notes, {
        Table_Col_2: title.trim(),
        Table_Col_3: desc.trim(),
        Table_Col_4: category.trim(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      print("Rows affected: $rowsEffected");
      return rowsEffected > 0;
    } catch (e) {
      print("Error adding note: $e");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getAllNotes() async {
    try {
      var db = await getDB();
      List<Map<String, dynamic>> result = await db.query(
        Table_Notes,
        orderBy: '$Table_Col_1 DESC',
      );
      print("Retrieved ${result.length} notes from database");
      return result;
    } catch (e) {
      print("Error getting all notes: $e");
      return [];
    }
  }

  Future<bool> updateNote({
    required int id,
    required String title,
    required String desc,
    required String category,
  }) async {
    try {
      if (title.trim().isEmpty ||
          desc.trim().isEmpty ||
          category.trim().isEmpty) {
        print("Invalid input data for update");
        return false;
      }

      var db = await getDB();
      int rowsEffected = await db.update(
        Table_Notes,
        {
          Table_Col_2: title.trim(),
          Table_Col_3: desc.trim(),
          Table_Col_4: category.trim(),
        },
        where: '$Table_Col_1 = ?',
        whereArgs: [id],
      );

      print("Update rows affected: $rowsEffected");
      return rowsEffected > 0;
    } catch (e) {
      print("Error updating note: $e");
      return false;
    }
  }

  Future<bool> deleteNote({required int id}) async {
    try {
      var db = await getDB();
      int rowsEffected = await db.delete(
        Table_Notes,
        where: '$Table_Col_1 = ?',
        whereArgs: [id],
      );

      print("Delete rows affected: $rowsEffected");
      return rowsEffected > 0;
    } catch (e) {
      print("Error deleting note: $e");
      return false;
    }
  }

  Future<void> closeDatabase() async {
    try {
      if (myDB != null) {
        await myDB!.close();
        myDB = null;
      }
    } catch (e) {
      print("Error closing database: $e");
    }
  }
}
