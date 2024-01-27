import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:nihongodict/common/global.dart';
import 'package:nihongodict/pages/home_page.dart';
import 'package:nihongodict/pages/notes_page.dart';
import 'package:nihongodict/pages/settings_page.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:nihongodict/utils/config_tool.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();
  packageInfo = await PackageInfo.fromPlatform();
  await ConfigTool().initConfig();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context)=>themeModeProvider,
        )
      ],
      child: MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModeProvider>(
      builder: (context, themeModeProvider, child) {
        return MaterialApp(
          theme: ThemeData(
            colorScheme: const ColorScheme.light(),
            textSelectionTheme: TextSelectionThemeData(
              selectionHandleColor: Colors.blueAccent,
              selectionColor: Colors.lightBlueAccent,
              cursorColor: Colors.blueAccent,
            )
          ),
          darkTheme: ThemeData(
            colorScheme: const ColorScheme.dark(),
            textSelectionTheme: TextSelectionThemeData(
              selectionHandleColor: Colors.blueAccent,
              selectionColor: Colors.lightBlueAccent,
              cursorColor: Colors.blueAccent,
            ),
          ),
          themeMode: themeModeProvider.themeMode,
          builder: BotToastInit(),
          navigatorObservers: [BotToastNavigatorObserver()],
          home: MyHomePage(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedPageIndex = 0;
  List<Widget> bottomNavPages = [];
  @override
  void initState() {
    super.initState();
    bottomNavPages.add(HomePage());
    bottomNavPages.add(NotesPage());
    bottomNavPages.add(SettingsPage());
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: bottomNavPages[selectedPageIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blueAccent,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '検索'),
          BottomNavigationBarItem(icon: Icon(Icons.sticky_note_2_outlined), label: 'お気に入り'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '設定'),
        ],
        currentIndex: selectedPageIndex,
        onTap: (index) {
          setState(() {
            selectedPageIndex = index;
          });
        },
      ),
    );
  }
}
