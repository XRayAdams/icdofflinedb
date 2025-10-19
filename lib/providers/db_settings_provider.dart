import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/code_selector.dart';
import '../models/result_model.dart';

class DbSettingsProvider with ChangeNotifier {
  late Database db;

  late List<CodeSection> sections;

  int _sectionIndex = 0;
  late CodeSection _selectedSection;

  List<ResultModel> resultList = <ResultModel>[];

  CodeSection get selectedSection => _selectedSection;

  set selectedSection(CodeSection selectedSection) {
    _selectedSection = selectedSection;
    _sectionIndex = selectedSection.id;
    _saveSettings();
    _search();
  }

  bool _icd9Diag = true;

  bool get icd9Diag => _icd9Diag;

  set icd9Diag(bool icd9diag) {
    _icd9Diag = icd9diag;
    _saveSettings();
    _search();
  }

  bool _icd9Proc = true;

  bool get icd9Proc => _icd9Proc;

  set icd9Proc(bool icd9Proc) {
    _icd9Proc = icd9Proc;
    _saveSettings();
    _search();
  }

  bool _icd10Diag = true;

  bool get icd10Diag => _icd10Diag;

  set icd10Diag(bool icd10Diag) {
    _icd10Diag = icd10Diag;
    _saveSettings();
    _search();
  }

  bool _icd10Proc = true;

  bool get icd10Proc => _icd10Proc;

  set icd10Proc(bool icd10Proc) {
    _icd10Proc = icd10Proc;
    _saveSettings();
    _search();
  }

  String _searchText = '';

  String get searchText => _searchText;

  set searchText(String searchText) {
    _searchText = searchText;
    _search();
  }

  bool isLoaded = false;
  bool isErrorLoadingDB = false;

  void _saveSettings() async {
    var pref = await SharedPreferences.getInstance();

    pref.setBool('icd9Diag', icd9Diag);
    pref.setBool('icd9Proc', icd9Proc);
    pref.setBool('icd10Diag', icd10Diag);
    pref.setBool('icd10Proc', icd10Proc);
    pref.setInt('sectionIndex', _sectionIndex);
  }

  Future<void> loadSettings() async {
    var pref = await SharedPreferences.getInstance();

    if (pref.containsKey('icd9Diag')) {
      try {
        _icd9Diag = pref.getBool('icd9Diag')!;
      } catch (e) {
        _icd9Diag = true;
      }
    }

    if (pref.containsKey('icd9Proc')) {
      try {
        _icd9Proc = pref.getBool('icd9Proc')!;
      } catch (e) {
        _icd9Proc = true;
      }
    }

    if (pref.containsKey('icd10Diag')) {
      try {
        _icd10Diag = pref.getBool('icd10Diag')!;
      } catch (e) {
        _icd10Diag = true;
      }
    }

    if (pref.containsKey('icd10Proc')) {
      try {
        _icd10Proc = pref.getBool('icd10Proc')!;
      } catch (e) {
        _icd10Proc = true;
      }
    }

    if (pref.containsKey('sectionIndex')) {
      try {
        _sectionIndex = pref.getInt('sectionIndex')!;
      } catch (e) {
        _sectionIndex = 0;
      }
    }

    await _loadDb();

    if(!isErrorLoadingDB) {
      // Get selected section from DB
      var tmp = sections.where((element) => element.id == _sectionIndex).toList();

      _selectedSection = tmp[0];

    }

    isLoaded = true;

    notifyListeners();
  }

  Future<void> _loadDb() async {
    final dbPath = "${path.dirname(Platform.resolvedExecutable)}/data/flutter_assets/assets/icddb.db";;

    try {
      db = await openDatabase(dbPath, readOnly: true);
    } catch (e) {
      isErrorLoadingDB = true;
      notifyListeners();
      return;
    }

    sections = await _loadSection();
  }

  Future<List<CodeSection>> _loadSection() async {
    final List<Map<String, dynamic>> maps = await db.query("CodeSections");

    return List.generate(maps.length, (i) {
      return CodeSection(
        id: maps[i]['id'],
        fromCode: maps[i]['FromCode'],
        toCode: maps[i]['ToCode'],
        description: maps[i]['Description'],
      );
    });
  }

  DbSettingsProvider() {
    loadSettings();
  }

  void _search() async {
    //Only search with at least 3 letters
    if (_searchText.length < 3) {
      return;
    }

    var queryStatementString =
        'select * from JoinedMaster '
        'where '
        '( '
        '(${icd9Diag ? 1 : 0} = 1 and CFK_ICDTYPE=2) or '
        '(${icd9Proc ? 1 : 0} = 1 and CFK_ICDTYPE=3) or '
        '(${icd10Diag ? 1 : 0} = 1 and CFK_ICDTYPE=0) or '
        '(${icd10Proc ? 1 : 0} = 1 and CFK_ICDTYPE=1) '
        ') '
        'and '
        '( description like "%$searchText%" or CODE like "%$searchText%" )'
        'and '
        '( '
        '$_sectionIndex = 0 or (substr(CODE,1,3)>="${_selectedSection.fromCode}" and substr(CODE,1,3)<="${_selectedSection.toCode}") '
        ') ';

    final List<Map<String, dynamic>> maps = await db.rawQuery(queryStatementString);

    resultList = List.generate(maps.length, (i) {
      return ResultModel(
        id: maps[i]['CPK_ICDMASTERLIST'],
        code: maps[i]['CODE'],
        description: maps[i]['DESCRIPTION'],
        rType: maps[i]['TYPE'],
        rTypeId: maps[i]['CFK_ICDTYPE:1'],
      );
    });

    notifyListeners();
  }

  Future<int> findProperId(bool isICD9, int id) async {
    var queryStatementString =
        'select ${isICD9 ? "ICD10" : "ICD9"} as NEWId from CrossWalk where ${isICD9 ? "ICD9" : "ICD10"} = $id';

    final List<Map<String, dynamic>> maps = await db.rawQuery(queryStatementString);

    if (maps.isNotEmpty) {
      return maps[0]['NEWId'];
    } else {
      return 0;
    }
  }

  Future<ResultModel?> getMasterRecord(int newId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      "JoinedMaster",
      where: "CPK_ICDMASTERLIST = ?",
      whereArgs: [newId],
    );

    if (maps.isNotEmpty) {
      return ResultModel(
        id: maps[0]['CPK_ICDMASTERLIST'],
        code: maps[0]['CODE'],
        description: maps[0]['DESCRIPTION'],
        rType: maps[0]['TYPE'],
        rTypeId: maps[0]['CFK_ICDTYPE:1'],
      );
    } else {
      return null;
    }
  }
}
