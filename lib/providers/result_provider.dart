import 'package:flutter/material.dart';

import '../models/result_model.dart';
import 'db_settings_provider.dart';

class ResultProvider with ChangeNotifier {
  ResultModel? result;
  ResultModel? conversion;
  DbSettingsProvider? dbProvider;
  bool isLoaded = false;

  bool? isICD9;

  void setResult(ResultModel model, DbSettingsProvider dbSettingsProvider) {
    result = model;
    dbProvider = dbSettingsProvider;
    isLoaded = false;
    notifyListeners();
    _doConversion();
  }

  Future<void> _doConversion() async {
    isICD9 = result!.rTypeId == 2 || result!.rTypeId == 3;

    int newId = await dbProvider!.findProperId(isICD9!, result!.id);

    if (newId > 0) {
      conversion = await dbProvider!.getMasterRecord(newId);

    }
    isLoaded = true;
    notifyListeners();
  }
}
