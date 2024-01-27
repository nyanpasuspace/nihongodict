import 'dart:convert';

import 'package:nihongodict/common/global.dart';
class Notebook {
  bool saveList(List<dynamic> savedList) {
    try {
      List<String> jsonList = savedList.map((e) => jsonEncode(e)).toList();
      prefs.setStringList('savedList', jsonList);
      return true;
    }
    catch(e) {
      print(e);
      return false;
    }
  }

  List<dynamic> getList() {
    List<String>? jsonList = prefs.getStringList('savedList') ?? [];
    final List<dynamic> list = jsonList!.map((e) => jsonDecode(e)).toList();
    return list;
  }

  bool isSavedItem(String url) {
    List<dynamic> list = getList();
    if(list.isEmpty) {
      return false;
    }
    for(var item in list) {
      List<dynamic> resultList = jsonDecode(item);
      if(resultList[4] == url) {
        return true;
      }
    }
    return false;
  }
}