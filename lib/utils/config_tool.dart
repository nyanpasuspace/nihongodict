import 'package:flutter/material.dart';
import 'package:nihongodict/common/global.dart';

class ConfigTool {
  Future<bool> initConfig() async {
    // prefs.clear();
    // prefs.setString('siteUrl', 'http://20.96.176.30');
    if(prefs.getBool('isDarkTheme') == null) {
      prefs.setBool('isDarkTheme', false);
    }
    themeModeProvider.isDarkTheme = prefs.getBool('isDarkTheme')!;
    themeModeProvider.themeMode = themeModeProvider.isDarkTheme ? ThemeMode.dark : ThemeMode.light;
    if(prefs.getStringList('savedList') == null) {
      prefs.setStringList('saveList', []);
    }
    savedList = nt.getList();
    savedListListener.value = savedList.isEmpty ? 0 : savedList.length;
    if(prefs.getStringList('historyList') == null) {
      prefs.setStringList('historyList', []);
    }
    if(prefs.getInt('searchType') != null) {
      searchType = prefs.getInt('searchType')!;
    }
    if(prefs.getString('siteUrl') != null) {
      siteUrl = prefs.getString('siteUrl')!;
      if(prefs.getBool('isRomajiUsed') == null) {
        prefs.setBool('isRomajiUsed', true);
      }
      if(prefs.getStringList('dicts') == null || prefs.getStringList('dicts')!.isEmpty) {
        List<String> dicts = await at.getDicts(prefs.getString('siteUrl')!);
        prefs.setStringList('dicts', dicts);
        if(dicts.isNotEmpty) {
          prefs.setString('dictGroupValue', dicts[0]);
        }
        else {
          prefs.setString('dictGroupValue', '');
        }
      }
      historyList = prefs.getStringList('historyList')!;
      dictsList = prefs.getStringList('dicts')!;
      if(prefs.getInt('usingDictIndex') == null) {
        // 默认第一本词典
        prefs.setInt('usingDictIndex', 0);
        usingDictIndex = 0;
        dictListener.value = 0;
      }
      else {
        usingDictIndex = prefs.getInt('usingDictIndex')!;
        dictListener.value = prefs.getInt('usingDictIndex')!;
      }
      return false;
    }
    else {
      // 注意，siteurl 为空，搜索无返回
      if(prefs.getBool('isRomajiUsed') == null) {
        prefs.setBool('isRomajiUsed', true);
      }
      prefs.setStringList('dicts', []);
      dictsList = prefs.getStringList('dicts')!;
      prefs.setString('dictGroupValue', '');
      return true;
    }
  }

  Future<bool> refreshConfig(String url) async {
    List<String> dicts = [];
    try {
      dicts = await at.getDicts(url);
    }
    catch(e) {
      return false;
    }
    print(dicts);
    // if(dicts.isEmpty) {
    //   return false;
    // }
    prefs.setString('siteUrl', url);
    siteUrl = url;
    prefs.setStringList('dicts', dicts);
    dictsList = prefs.getStringList('dicts')!;
    prefs.setInt('usingDictIndex', 0);
    usingDictIndex = 0;
    dictListener.value = 0;
    return true;
  }
}
