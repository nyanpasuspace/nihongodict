import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nihongodict/common/global.dart';
import 'package:nihongodict/pages/about_page.dart';
import 'package:nihongodict/utils/config_tool.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController sourceController = TextEditingController();
  FocusNode focusNode = FocusNode();
  bool isLoading = false;
  bool isUrl(String url) {
    final RegExp regex = RegExp(r'(http|ftp|https):\/\/[\w\-_]+(\.[\w\-_]+)+([\w\-\.,@?^=%&amp;:/~\+#]*[\w\-\@?^=%&amp;/~\+#])?');
    return regex.hasMatch(url);
  }

  // TODO 写进有状态组件
  Future<void> showSourceInputField() async {
    String? errorText = null;
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return WillPopScope(
                  onWillPop: () async {
                    if (isLoading) {
                      return false;
                    }
                    return true;
                  },
                  child: isLoading
                      ? AlertDialog(
                          // TODO 修改圆角大小
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          surfaceTintColor: themeModeProvider.isDarkTheme ? Colors.black : Colors.white,
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ],
                          ),
                        )
                      : AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          surfaceTintColor: themeModeProvider.isDarkTheme ? Colors.black : Colors.white,
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                  contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                  title: Text('ソース設定', style: TextStyle(fontSize: 20)),
                                  subtitle: TextFormField(
                                    controller: sourceController,
                                    decoration: InputDecoration(
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                      hintText: siteUrl,
                                      errorText: errorText,
                                      errorMaxLines: 2
                                    ),
                                    maxLines: 1,
                                    minLines: 1,
                                    keyboardType: TextInputType.url,
                                    textInputAction: TextInputAction.done,
                                    autofocus: false,
                                    onChanged: (value) {
                                      setState(() {
                                        errorText = null;
                                      });
                                    },
                                  )),
                              ButtonBar(
                                children: <Widget>[
                                  TextButton(
                                    child: Text('キャンセル',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: themeModeProvider.isDarkTheme ? Colors.white : Colors.black)),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  TextButton(
                                    child: Text('設定', style: TextStyle(fontSize: 18, color: Colors.red)),
                                    onPressed: () async {
                                      if (isUrl(sourceController.text)) {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        if (await ConfigTool().refreshConfig(sourceController.text)) {
                                          isLoading = false;
                                          Navigator.pop(context);
                                          showDialog(
                                              barrierDismissible: false,
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    surfaceTintColor:
                                                    themeModeProvider.isDarkTheme ? Colors.black : Colors.white,
                                                    content: Column(mainAxisSize: MainAxisSize.min, children: [
                                                      ListTile(
                                                          leading: Icon(
                                                            Icons.check,
                                                            color: Colors.green,
                                                            size: 20,
                                                          ),
                                                          title: Text('データソースの設定が成功しました', style: TextStyle(fontSize: 20)),
                                                          contentPadding: EdgeInsets.only(left: 10, right: 10)),
                                                      ButtonBar(children: <Widget>[
                                                        TextButton(
                                                          child: Text('確認',
                                                              style: TextStyle(fontSize: 18, color: Colors.blueAccent)),
                                                          onPressed: () {
                                                            Navigator.pop(context);
                                                          },
                                                        )
                                                      ]),
                                                    ]));
                                              });
                                        }
                                        else {
                                          isLoading = false;
                                          Navigator.pop(context);
                                          showDialog(
                                              barrierDismissible: false,
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    surfaceTintColor:
                                                        themeModeProvider.isDarkTheme ? Colors.black : Colors.white,
                                                    content: Column(mainAxisSize: MainAxisSize.min, children: [
                                                      ListTile(
                                                          leading: Icon(
                                                            Icons.warning,
                                                            color: Colors.red,
                                                            size: 20,
                                                          ),
                                                          title: Text('データソースにエラーが発生しました', style: TextStyle(fontSize: 20)),
                                                          contentPadding: EdgeInsets.only(left: 10, right: 10)),
                                                      ButtonBar(children: <Widget>[
                                                        TextButton(
                                                          child: Text('確認',
                                                              style: TextStyle(fontSize: 18, color: Colors.blueAccent)),
                                                          onPressed: () {
                                                            Navigator.pop(context);
                                                          },
                                                        )
                                                      ]),
                                                    ]));
                                              });
                                        }
                                      } else {
                                        errorText = 'http://またはhttps://で始まるURLを入力して';
                                        setState(() {});
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ));
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          scrolledUnderElevation: 0.0,
          title: Container(
            padding: EdgeInsets.only(left: 15),
            child: Text("設定"),
          )),
      body: Container(
        margin: const EdgeInsets.all(0),
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    margin: EdgeInsets.only(left: 15),
                    child: Icon(Icons.mode_night_sharp),
                  ),
                  title: Text('ダークモード', style: TextStyle(fontSize: 20)),
                  subtitle: Text(themeModeProvider.isDarkTheme == true ? 'On' : 'Off', style: TextStyle(fontSize: 14)),
                  minVerticalPadding: 10,
                  trailing: Switch(
                      value: themeModeProvider.isDarkTheme,
                      activeTrackColor: Colors.blueAccent,
                      activeColor: Colors.white,
                      onChanged: (value) {
                        setState(() {
                          themeModeProvider.switchThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                          print(themeModeProvider.isDarkTheme);
                        });
                      }),
                ),
                ListTile(
                  leading: Container(
                    margin: EdgeInsets.only(left: 15),
                    child: Icon(Icons.settings_input_composite_sharp),
                  ),
                  title: Text('データソース設定', style: TextStyle(fontSize: 20)),
                  subtitle: Text(prefs.getString('siteUrl').toString(),
                      style: TextStyle(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                  minVerticalPadding: 10,
                  onTap: () async {
                    await showSourceInputField();
                    setState(() {

                    });
                  },
                ),
                ListTile(
                  leading: Container(
                    margin: EdgeInsets.only(left: 15),
                    child: Icon(Icons.info),
                  ),
                  title: Text('アプリについて', style: TextStyle(fontSize: 20)),
                  subtitle: Text('このアプリについてのインフォ', style: TextStyle(fontSize: 14)),
                  minVerticalPadding: 10,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AboutPage()));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    sourceController.dispose();
    focusNode.dispose();
  }
}
