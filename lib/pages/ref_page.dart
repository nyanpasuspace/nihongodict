import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:nihongodict/common/global.dart';
import 'package:nihongodict/pages/item_detail_page.dart';
import 'package:url_launcher/url_launcher.dart';

class RefItemPage extends StatefulWidget {
  final String refUrl;
  const RefItemPage({
    Key? key,
    required this.refUrl
  }) : super(key: key);
  @override
  _RefItemPageState createState() => _RefItemPageState();
}

class _RefItemPageState extends State<RefItemPage> {
  void openURL(url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw '无法启动 $url';
    }
  }
  late StateSetter reloadTextSetter;
  // TODO 加载器
  @override
  Widget build(BuildContext context) {
    // print(widget.refUrl);
    return FutureBuilder(
        future: at.getTango(widget.refUrl),
        builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: themeModeProvider.isDarkTheme ? Colors.black : Colors.white,
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.blueAccent,
                ),
              ),
            );
          }
          else {
            if(snapshot.data == null || snapshot.data!.isEmpty || snapshot.data == {}) {
              // TODO 报错页面
              return Container();
            }
            else {
              final snapshotData = snapshot.data;
              late String itemUrl;
              if(snapshotData != null) {
                itemUrl = contentConverter.contentUrlGenerator(snapshotData!);
              }
              return StatefulBuilder(
                builder: (BuildContext context, StateSetter stateSetter) {
                  reloadTextSetter = stateSetter;
                  return Scaffold(
                      appBar: AppBar(
                        scrolledUnderElevation: 0.0,
                        title: Text(snapshot.data!['heading'].toString()),
                        leading: IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        actions: [
                          Tooltip(
                            message: '添加到生词本',
                            child: Container(
                              margin: EdgeInsets.only(right: 5),
                              child: IconButton(
                                icon: nt.isSavedItem(itemUrl) ? Icon(Icons.star, color: Colors.yellow, size: 30) : Icon(Icons.star_border, size: 30),
                                onPressed: () {
                                  // 收藏
                                  snapshot.data!['url'] = itemUrl;
                                  Map<String, dynamic> data = snapshot.data!;
                                  data['isEditing'] = false;
                                  // data['text'] = contentConverter.parser(data['text']);
                                  // TODO 转义内容，且注意收藏功能有效性
                                  List<dynamic> dataList = data.values.toList();
                                  if(nt.isSavedItem(itemUrl)) {
                                    List<String> jsonList = dataList.map((e) => jsonEncode(e)).toList();
                                    savedList.remove(jsonList.toString());
                                    if(nt.saveList(savedList)) {
                                      var cancel = BotToast.showText(text: '取消收藏成功');
                                    }
                                    else {
                                      var cancel = BotToast.showText(text: '取消收藏失败');
                                      savedList.add(jsonList);
                                      nt.saveList(savedList);
                                    }
                                  }
                                  else {
                                    List<String> jsonList = dataList.map((e) => jsonEncode(e)).toList();
                                    savedList.add(jsonList.toString());
                                    if(nt.saveList(savedList)) {
                                      var cancel = BotToast.showText(text: '收藏成功');
                                    }
                                    else {
                                      var cancel = BotToast.showText(text: '收藏失败');
                                      savedList.add(jsonList);
                                      nt.saveList(savedList);
                                    }
                                  }
                                  savedListListener.value = savedList.isEmpty ? 0 : savedList.length;
                                  // setState(() {
                                  //
                                  // });
                                  reloadTextSetter(() {});
                                },
                              ),
                            ),
                          ),
                          Tooltip(
                              message: '查看网页',
                              child: Container(
                                margin: EdgeInsets.only(right: 20),
                                child: IconButton(
                                  icon: Icon(Icons.language),
                                  onPressed: () {
                                    openURL(Uri.parse(itemUrl));
                                  },
                                ),
                              )
                          )
                        ],
                      ),
                      body: ItemDetailPage(wordData: snapshot.data!)
                  );
                },
              );
            }
          }
        }
    );
  }
}
