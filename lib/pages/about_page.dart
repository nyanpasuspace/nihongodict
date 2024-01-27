import 'dart:convert';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../common/global.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({
    Key? key,
  }) : super(key: key);
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String updateInfo = "";
  Map resInfo = {};

  void openURL(url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw '无法启动 $url';
    }
  }

  Future<String> getDownloadUrl(Map maps) async {
    String url = "";
    for (var m in maps['assets']) {
      if (m['name'] == 'app-release.apk') {
        // print(m['browser_download_url']);
        return m['browser_download_url'];
      }
    }
    return url;
  }

  Future<bool> compareVersion(String version, String newVersion) async {
    List<int> parts1 = version.split('.').map(int.parse).toList();
    List<int> parts2 = newVersion.split('.').map(int.parse).toList();

    int length = parts1.length < parts2.length ? parts1.length : parts2.length;
    // 暂不考虑版本号长度不一致
    int compareResult = 0;
    for (int i = 0; i < length; i++) {
      if (parts1[i] < parts2[i]) {
        compareResult = -1;
        break;
      } else if (parts1[i] > parts2[i]) {
        compareResult = 1;
        break;
      }
    }
    if (compareResult >= 0) {
      return false;
    } else {
      return true;
    }
  }

  Future<bool> checkUpdate(String version) async {
    var cancel = BotToast.showText(text: 'チェックしてます～', duration: Duration(seconds: 5));
    final response = await http.get(Uri.parse('https://api.github.com/repos/maodaisuki/nihongodict/releases/latest')).timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        cancel();
        return http.Response('Error', 408);
      },
    );

    if (response.statusCode == 200) {
      final release = jsonDecode(response.body);
      final newVersion = release['tag_name'].substring(1);
      print("newVersion: $newVersion");
      if (await compareVersion(version, newVersion)) {
        // 有新版本
        updateInfo = release['body'];
        resInfo = release;
        // print(resInfo['assets'][0]['browser_download_url']);
        cancel();
        return true;
      } else {
        print("没有新版本");
        cancel();
        return false;
      }
    }
    else {
      print("网络问题");
    }
    return false;
  }

  Future<void> showUpdateInfo(bool info) async {
    if (info) {
      // 有新版本
      await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) => AlertDialog(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
            title: Text("发现新版本"),
            content: Text("立即前往下载？", style: TextStyle(fontSize: 18)),
            actions: <Widget>[
              TextButton(
                  child: Text('キャンセル', style: TextStyle(fontSize: 18, color: themeModeProvider.isDarkTheme ? Colors.white: Colors.black)),
                  onPressed: () async {
                    // 取消跳转页面
                    Navigator.pop(context);
                  }),
              TextButton(
                  child: const Text('確認',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                      )),
                  onPressed: () async {
                    // 跳转页面
                    String url = await getDownloadUrl(resInfo);
                    openURL(Uri.parse(url));
                    Navigator.pop(context);
                  }),
            ],
          ));
    } else {
      // 没有新版本
      await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) => AlertDialog(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
            title: Text("检查更新"),
            content: Text("暂未发现新版本", style: TextStyle(fontSize: 18)),
            actions: <Widget>[
              TextButton(
                  child: Text('確認', style: TextStyle(fontSize: 18, color: themeModeProvider.isDarkTheme ? Colors.white: Colors.black)),
                  onPressed: () async {
                    Navigator.pop(context);
                  }),
            ],
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text("关于软件", style: TextStyle(color: themeConfig['titleColor'])),
        leading: Builder(builder: (context) {
          return IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          );
        }),
      ),
      body: Container(
        margin: const EdgeInsets.all(0),
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: Image.asset(
                        'lib/assets/nihongodict.png',
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Center(
                    child: Text('日本語辞典',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10),
                  child: Center(
                    child: Text("Version ${packageInfo.version} -release", style: TextStyle(fontSize: 16)),
                  ),
                ),
                ListTile(
                  leading: Container(
                    margin: EdgeInsets.only(left: 15),
                    child: Icon(Icons.emoji_emotions),
                  ),
                  title: Text('日本語辞典のソースコード', style: TextStyle(fontSize: 20)),
                  subtitle: Text('GitHub のリポジトリへ', style: TextStyle(fontSize: 14)),
                  minVerticalPadding: 10,
                  onTap: () {
                    print("打开官网");
                    openURL(Uri.parse('https://github.com/maodaisuki/nihongodict/'));
                  },
                ),
                ListTile(
                  leading: Container(
                    margin: EdgeInsets.only(left: 15),
                    child: Icon(Icons.rocket_launch),
                  ),
                  title: Text('アップデートチェック', style: TextStyle(fontSize: 20)),
                  subtitle:
                  Text('新しいバージョンチェックすること', style: TextStyle(fontSize: 14)),
                  minVerticalPadding: 10,
                  onTap: () async {
                    await showUpdateInfo(await checkUpdate(packageInfo.version.toString()));
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
  }
}