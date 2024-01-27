import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nihongodict/common/global.dart';
import 'package:nihongodict/widgets/saved_item_widget.dart';
import 'package:nihongodict/widgets/search_bar_widget.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  FocusNode focusNode = FocusNode();
  TextEditingController queryController = TextEditingController();
  List<dynamic> savedListTemp = savedList.map((e) => jsonDecode(e)).toList();
  @override
  void initState() {
    dataList = savedListTemp;
  }

  bool isAllSelected() {
    for(var item in dataList) {
      if(!item[5]) {
        return false;
      }
    }
    return true;
  }

  void selectAll() {
    bool isSelected = false;
    for(var item in dataList) {
      if(item[5]) {
        isSelected = true;
        break;
      }
    }
    if(isSelected) {
      for(var item in dataList) {
        item[5] = false;
      }
    }
    else {
      for(var item in dataList) {
        item[5] = true;
      }
    }
  }

  void deleteAllSelectedItem() {
    // TODO 优化
    List<dynamic> dataListCopy = [];
    dataListCopy.addAll(dataList);
    List<dynamic> savedListCopy = savedList.map((e) => jsonDecode(e)).toList();

    dataList.removeWhere((element) => element[5] == true);
    dataListCopy.removeWhere((element) => element[5] == false);

    for(var item in savedListCopy) {
      for(var data in dataListCopy) {
        if(data[4] == item[4]) {
          item[5] = true;
        }
      }
    }
    savedListCopy.removeWhere((element) => element[5] == true);
    savedList = savedListCopy.map((e) => jsonEncode(e)).toList();
    nt.saveList(savedList);
    // dataList = savedList.map((e) => jsonDecode(e)).toList();
    // List<dynamic> dataCopy = dataList;
    // // 删除收藏页中的选中项
    // dataList.removeWhere((element) => element[5] == true);
    // // 以下删除实际数据中的选中项 savedList
    // dataCopy.removeWhere((element) => element[5] == false);
    // List<dynamic> tempList = savedList.map((e) => jsonDecode(e)).toList();
    // tempList.removeWhere((element) => dataCopy.contains(element));
    // print(dataCopy.toString() + "\n" + savedList.toString());
    // savedList = tempList.map((e) => jsonEncode(e)).toList();
    // nt.saveList(savedList);
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> tempList = [];
    for(var item in dataList) {
      // 检查 heading 和 text
      if(item[0].toString().contains(queryController.text) || item[1].toString().contains(queryController.text) || queryController.text.isEmpty) {
        tempList.add(item);
      }
    }
    dataList = tempList;
    return Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0.0,
            title: Text('お気に入り'),
            actions: [
              Container(
                margin: EdgeInsets.only(right: 5),
                child: IconButton(
                  icon: isEditing ? Icon(Icons.close) : Icon(Icons.edit),
                  onPressed: dataList.isEmpty ? null : () {
                    setState(() {
                      isEditing = !isEditing;
                    }
                   );
                  },
                )
              ),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(48.0),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                child: SearchAppBar(
                  onTapOutside: () {
                    focusNode.unfocus();
                  },
                  onChanged: (value) {
                    List<dynamic> tempList = [];
                    dataList = savedList.map((e) => jsonDecode(e)).toList();
                    for(var item in dataList) {
                      // 检查 heading 和 text
                      if(item[0].toString().contains(queryController.text) || item[1].toString().contains(queryController.text) || queryController.text.isEmpty) {
                        tempList.add(item);
                      }
                    }
                    dataList = tempList;
                    setState(() {

                    });
                  },
                  onClearAll: () {
                    dataList = savedList.map((e) => jsonDecode(e)).toList();
                    setState(() {

                    });
                  },
                  onSubmitted: (value) async {},
                  queryController: queryController,
                  focusNode: focusNode,
               ),
              )
            ),
          ),
          body: Column(
                children: [
                  dataList.isEmpty || dataList == []
                      ? Expanded(
                    child: Center(
                      child: Text('这里什么也没有～', style: TextStyle(fontSize: 18))
                    )
                  )
                      : Expanded(
                    child: ListView.builder(
                      itemCount: dataList.length,
                      itemBuilder: (context, index) {
                        return SavedListItem(
                          index: index,
                          onBack: () {
                            setState(() {

                            });
                          },
                          onSelected: () {
                            setState(() {

                            });
                          },
                          deleteItem: (index) {
                            dataList.removeAt(index);
                            savedList = dataList.map((e) => jsonEncode(e)).toList();
                            nt.saveList(savedList);
                            setState(() {

                            });
                          },
                        );
                      }
                    ),
                  ),
                ],
          ),
          bottomSheet: isEditing
            ? Container(
              padding: EdgeInsets.only(left: 10, right: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.25),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, -0.1),
                      ),
                    ],
                  ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: EdgeInsets.all(5),
                    child: TextButton.icon(
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                          return Theme.of(context).splashColor;
                        }),
                      ),
                      icon: isAllSelected() ? Icon(Icons.check_box, color: Colors.blueAccent) : Icon(Icons.check_box_outline_blank, color: Theme.of(context).iconTheme.color),
                      label: Text('全選択', style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.labelLarge!.color)),
                      onPressed: () {
                        selectAll();
                        setState(() {

                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: Container(height: 0)
                  ),
                  Container(
                    margin: EdgeInsets.all(5),
                    child: TextButton(
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                          return Theme.of(context).splashColor;
                        }),
                      ),
                      child: Text('削除', style: TextStyle(color: Colors.red, fontSize: 18)),
                      onPressed: () {
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
                                        title: Text('确认将所有选中条目从收藏移出？', style: TextStyle(fontSize: 20)),
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
                                          deleteAllSelectedItem();
                                          isEditing = false;
                                          setState(() {

                                          });
                                          Navigator.pop(context);
                                        },
                                      )
                                    ]),
                                  ]));
                            });
                      },
                  ),
                )
              ],
            )
          ): null,
        );
  }

  @override
  void dispose() {
    super.dispose();
    focusNode.dispose();
    queryController.dispose();
    isEditing = false;
  }
}
