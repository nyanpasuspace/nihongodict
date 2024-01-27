import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:nihongodict/common/global.dart';
import 'package:nihongodict/pages/item_detail_page.dart';
import 'package:nihongodict/pages/notes_page.dart';
import 'package:url_launcher/url_launcher.dart';

class SavedItemPage extends StatefulWidget {
  final List<dynamic> data;
  final Function() onBack;
  const SavedItemPage({
    Key? key,
    required this.data,
    required this.onBack,
  }) : super(key: key);
  @override
  _SavedItemPageState createState() => _SavedItemPageState();
}

class _SavedItemPageState extends State<SavedItemPage> {
  void openURL(url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw '无法启动 $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    String itemUrl = widget.data[0]['url'];
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        title: Text(widget.data[0]['heading'].toString()),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            widget.onBack();
            Navigator.pop(context, savedList);
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
                  Map<String, dynamic> data = widget.data[0];
                  data['isEditing'] = false;
                  // data['text'] = contentConverter.parser(data['text']);
                  // TODO 转义内容，且注意收藏功能有效性
                  List<dynamic> dataList = data.values.toList();
                  if(nt.isSavedItem(itemUrl)) {
                    List<String> jsonList = dataList.map((e) => jsonEncode(e)).toList();
                    savedList.remove(jsonList.toString());
                    if(nt.saveList(savedList)) {
                      // var cancel = BotToast.showText(text: 'お気に入りから\n削除しました');
                    }
                    else {
                      // var cancel = BotToast.showText(text: 'お気に入りから\n削除できませんでした');
                      savedList.add(jsonList);
                      nt.saveList(savedList);
                    }
                  }
                  else {
                    List<String> jsonList = dataList.map((e) => jsonEncode(e)).toList();
                    savedList.add(jsonList.toString());
                    if(nt.saveList(savedList)) {
                      // var cancel = BotToast.showText(text: 'お気に入りに\n追加しました');
                    }
                    else {
                      // var cancel = BotToast.showText(text: 'お気に入りに\n追加できませんでした');
                      savedList.add(jsonList);
                      nt.saveList(savedList);
                    }
                  }
                  setState(() {
                    savedListListener.value = savedList.isEmpty ? 0 : savedList.length;
                    dataList.clear();
                  });
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
      body: ItemDetailPage(wordData: widget.data[0]),
    );
  }
}
