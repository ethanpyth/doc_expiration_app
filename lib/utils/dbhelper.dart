import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:async';
import 'dart:io';

import '../model/model.dart';

class DbHelper {
  static String tblDocs = "docs";

  String docId = "id";
  String docTitle = "title";
  String docExpiration = "expiration";

  String fqYear = "fqYear";
  String fqHalfYear = "fqHalfYear";
  String fqQuarter = "fqQuarter";
  String fqMonth = "fqMonth";

  static late final DbHelper _dbHelper = DbHelper._internal();

  DbHelper._internal();

  factory DbHelper() {
    return _dbHelper;
  }

  static late Database _db;

  Future<Database> get db async {
    _db = await initializeDb();

    return _db;
  }

  Future<Database> initializeDb() async {
    Directory d = await getApplicationDocumentsDirectory();
    String p = d.path + "/docexpire.db";
    var db = await openDatabase(p, version: 1, onCreate: _createDb);
    return db;
  }

  void _createDb(Database db, int version) async {
    await db.execute(
        "CREATE TABLE $tblDocs($docId INTEGER PRIMARY KEY, $docTitle TEXT, " +
            "$docExpiration TEXT, " +
            "$fqYear INTEGER, $fqHalfYear INTEGER, $fqQuarter INTEGER, " +
            "$fqMonth INTEGER");
  }

  Future<int> insertDoc(Doc doc) async {
    late int r;
    Database db = await this.db;
    try {
      r = await db.insert(tblDocs, doc.toMap());
    } catch (e) {
      debugPrint("insertDoc: " + e.toString());
    }
    return r;
  }

  Future<List> getDocs() async {
    Database db = await this.db;
    var r =
        await db.rawQuery("SELECT * FROM $tblDocs ORDER BY $docExpiration ASC");
    return r;
  }

  Future<List> getDoc(int id) async {
    Database db = await this.db;
    var r = await db.rawQuery(
        "SELECT * FROM $tblDocs WHERE $docId = " + id.toString() + "");
    return r;
  }

  Future<List?> getDocFromStr(String payload) async {
    List<String> p = payload.split("|");
    if (p.length == 2) {
      Database db = await this.db;
      var r = await db.rawQuery("SELECT * FROM $tblDocs WHERE $docId = " +
          p[0] +
          " AND $docExpiration = '" +
          p[1] +
          "'");
      return r;
    } else {
      return null;
    }
  }

  Future<int?> getDocsCount() async {
    Database db = await this.db;
    var r = Sqflite.firstIntValue(
        await db.rawQuery("SELECT COUNT(*) FROM $tblDocs"));

    return r;
  }

  Future<int?> getMaxId() async {
    Database db = await this.db;
    var r = Sqflite.firstIntValue(
        await db.rawQuery("SELECT MAX(id) FROM $tblDocs"));
    return r;
  }

  Future<int> updateDoc(Doc doc) async {
    var db = await this.db;
    var r = await db
        .update(tblDocs, doc.toMap(), where: "$docId = ?", whereArgs: [doc.id]);
    return r;
  }

  Future<int> deleteDoc(int id) async {
    var db = await this.db;
    var r = await db.rawDelete("DELETE FROM $tblDocs WHERE $docId = $id");
    return r;
  }

  Future<int> deleteRows(String tbl) async {
    var db = await this.db;
    var r = await db.rawDelete("DELETE FROM $tbl");
    return r;
  }
}
