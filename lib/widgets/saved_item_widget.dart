import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nihongodict/common/global.dart';
import 'package:nihongodict/pages/saved_item_page.dart';
import 'package:nihongodict/pages/tango_item_page.dart';

class SavedListItem extends StatefulWidget {
  final int index;
  final Function() onBack;
  final Function() onSelected;
  final Function(int index) deleteItem;
  const SavedListItem({
    Key? key,
    required this.index,
    required this.onBack,
    required this.onSelected,
    required this.deleteItem,
  }) : super(key: key);
  @override
  _SavedListItemState createState() => _SavedListItemState();
}

class _SavedListItemState extends State<SavedListItem> {
  @override
  Widget build(BuildContext context) {
    List<dynamic> data = [{
      'heading': dataList[widget.index][0],
      'text': dataList[widget.index][1],
      'page': dataList[widget.index][2],
      'offset': dataList[widget.index][3],
      'url': dataList[widget.index][4],
    }];
    return GestureDetector(
      child: Card(
        color: themeModeProvider.isDarkTheme ? Colors.white10 : Colors.white70,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        margin: widget.index == dataList.length - 1 ? EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 80) : EdgeInsets.only(top: 5, left: 10, right: 10),
        child: ListTile(
          enabled: !isEditing,
          contentPadding: EdgeInsets.only(left: 20, right: 20),
          leading: Icon(Icons.cloud),
          // 条目标题
          title: Text(dataList[widget.index][0].replaceAll('\n', '\n\n')
            .replaceFirst('[keyword]', '').replaceAll('[keyword]', '').replaceAll('[/keyword]', '')
            .replaceAll('[decoration]', '').replaceAll('[/decoration]', '')
            .replaceAll('[subscript]', '').replaceAll('[/subscript]', '')
            .replaceAll('{{zb468}}', '⇔'), overflow: TextOverflow.ellipsis, maxLines: 1),
          // 条目介绍
          subtitle: Text(dataList[widget.index][1].toString().replaceAll('\n', '').replaceAll('\n', '\n\n')
            .replaceFirst('[keyword]', '').replaceAll('[keyword]', '').replaceAll('[/keyword]', '')
            .replaceAll('[decoration]', '').replaceAll('[/decoration]', '')
            .replaceAll('[subscript]', '').replaceAll('[/subscript]', '')
            .replaceAll('[/image]オ', '[/image]')
            .replaceAll(RegExp(r'\[wav\s+page=(\d+),offset=(\d+),endpage=(\d+),endoffset=(\d+)\](.*?)\[/wav\]'), '')
            .replaceAll(RegExp(r'\[image\s+format=([A-Za-z]+),inline=(\d+),page=(\d+),offset=(\d+)\]([\s\S]*?)\[/image\]'), '')
            .replaceAll('{{zb468}}', '⇔'), overflow: TextOverflow.ellipsis, maxLines: 1),
          trailing: isEditing ?  IconButton(
            icon: dataList[widget.index][5] ? Icon(Icons.check_box, color: Colors.blueAccent) : Icon(Icons.check_box_outline_blank, color: Theme.of(context).iconTheme.color),
            onPressed: () {
              dataList[widget.index][5] = !dataList[widget.index][5];
              widget.onSelected();
            },
          ) : null,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SavedItemPage(
                  data: data,
                  onBack: () {
                    widget.onBack();
                  },
                )
              )
            ).then((savedList) {
              dataList = savedList.map((e) => jsonDecode(e)).toList();
            });
          },
        )
      ),
      onLongPressStart: (details) {
        if(!isEditing) {
          showMenu(
            context: context,
            position: RelativeRect.fromLTRB(
              details.globalPosition.dx,
              details.globalPosition.dy,
              details.globalPosition.dx,
              details.globalPosition.dy,
            ),
            items: <PopupMenuEntry>[
              PopupMenuItem(child: Text("删除", style: TextStyle(fontSize: 18)), onTap: () {
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
                                title: Text('确认将${dataList[widget.index][0]}从收藏移出？', style: TextStyle(fontSize: 20)),
                                contentPadding: EdgeInsets.only(left: 10, right: 10)),
                            ButtonBar(children: <Widget>[
                              TextButton(
                                child: Text('取消',
                                    style: TextStyle(fontSize: 18, color: themeModeProvider.isDarkTheme ? Colors.white : Colors.black)),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              TextButton(
                                child: Text('确定',
                                    style: TextStyle(fontSize: 18, color: Colors.red)),
                                onPressed: () {
                                  widget.deleteItem(widget.index);
                                  Navigator.pop(context);
                                },
                              )
                            ]),
                          ]));
                    });
              }), // Menu Item
            ],
          );
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}