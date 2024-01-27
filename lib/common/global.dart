import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nihongodict/utils/content_generator.dart';
import 'package:nihongodict/utils/notebook.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/api.dart';

ThemeModeProvider themeModeProvider = ThemeModeProvider();
ContentConverter contentConverter = ContentConverter();
bool isSearched = false;
ApiTool at = ApiTool();
late Map config;
String siteUrl = '';
late SharedPreferences prefs;
List<String> dictsList = [];
int usingDictIndex = 0;
List<String> historyList = [];
List<dynamic> searchResultList = [];
List<dynamic> savedList = [];
List<dynamic> dataList = savedList.map((e) => jsonDecode(e)).toList();
int searchType = 0;
String query = '';
bool isEditing = false;
Notebook nt = Notebook();
// 转化为 1 0
bool isRomajiUsed = true;
ValueNotifier<int> dictListener = ValueNotifier<int>(0);
ValueNotifier<int> savedListListener = ValueNotifier<int>(0);
PackageInfo packageInfo = PackageInfo(
  appName: 'Unknown',
  packageName: 'Unknown',
  version: 'Unknown',
  buildNumber: 'Unknown',
  buildSignature: 'Unknown',
  installerStore: 'Unknown',
);

class ThemeModeProvider with ChangeNotifier {
  bool isDarkTheme = false;
  ThemeMode themeMode = ThemeMode.light;
  void switchThemeMode(ThemeMode mode) {
    isDarkTheme = !isDarkTheme;
    themeMode = mode;
    prefs.setBool('isDarkTheme', themeModeProvider.isDarkTheme);
    notifyListeners();
  }
}