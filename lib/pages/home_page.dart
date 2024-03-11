import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nihongodict/widgets/drawer_widget.dart';
import 'package:nihongodict/widgets/search_bar_widget.dart';
import 'package:nihongodict/common/global.dart';
import 'package:nihongodict/widgets/search_result_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/history_widgtet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FocusNode focusNode = FocusNode();
  TextEditingController queryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isSearched = false;
  }

  void openURL(url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw '无法启动 $url';
    }
  }

  void showRomajiInfo() {
    BotToast.defaultOption.notification.animationDuration=const Duration(seconds: 1);
    if(isRomajiUsed) {
      var cancel = BotToast.showText(text: 'ローマ字変換: On');
    }
    else {
      var cancel = BotToast.showText(text: 'ローマ字変換: Off');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> typeArray = ['前方一致', '後方一致', '完全一致'];
    String setType = typeArray[searchType];
    List<bool> isRomajiUsedList = [prefs.getBool('isRomajiUsed')!];
    // Future<List<String>> fetchData() async {
    //   await Future.delayed(Duration(seconds: 2)); // 模拟网络请求
    //   return ['item1', 'item2', 'item3'];
    // }

    Future<List<dynamic>> searchFuture() async {
      // print(siteUrl);
      Map temp = await at.searchDict(siteUrl, {
        'q': query,
        'dict': dictsList.isNotEmpty ? dictsList[usingDictIndex].toString() : '広辞苑',
        'type': searchType.toString(),
        'romaji': isRomajiUsed ? '1' : '0',
        'max': '20',
        // TODO 关于 max 的调整
      });

      searchResultList = temp['words'] == null ? [] : temp['words'];
      return searchResultList;
    }
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                isSearched = false;
                query = '';
                queryController.text = '';
                setState(() {

                });
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          Tooltip(
            message: 'Romaji 转换',
            child: ToggleButtons(
              color: Theme.of(context).toggleButtonsTheme.color,
              isSelected: isRomajiUsedList,
              selectedColor: ThemeMode.values == ThemeMode.light ? Colors.deepPurpleAccent : Colors.blueAccent,
              fillColor: Colors.transparent,
              selectedBorderColor: Colors.transparent,
              borderColor: Colors.transparent,
              splashColor: Theme.of(context).splashColor,
              children: <Widget>[
                Icon(Icons.translate),
              ],
              onPressed: (int index) {
                setState(() {
                  isRomajiUsed = !prefs.getBool('isRomajiUsed')!;
                  prefs.setBool('isRomajiUsed', isRomajiUsed);
                  showRomajiInfo();
                });
              },
            ),
          ),
          DropdownButton(
            padding: EdgeInsets.only(left: 10),
            icon: Icon(Icons.arrow_drop_down_rounded),
            value: setType,
            items: typeArray
                .map((String item) => DropdownMenuItem<String>(
              key: Key(item),
              value: item,
              child: Text(item),
            )).toList(),
            selectedItemBuilder: (BuildContext context) {
              return typeArray.map<Widget>((String item) {
                return Center(
                  child: Text(item),
                );
              }).toList();
            },
            onChanged: (value) {
              setState(() {
                int index = typeArray.indexOf(value!);
                prefs.setInt('searchType', index);
                searchType = index;
                print(value);
              });
            },
            underline: Container(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child: SearchAppBar(
              onTapOutside: () {
                focusNode.unfocus();
                if(!isSearched) {
                  setState(() {

                  });
                }
              },
              onChanged: (value){
                if(value.isEmpty) {
                  setState(() {
                    isSearched = false;
                  });
                }
              },
              onClearAll: () {
                setState(() {
                  isSearched = false;
                  query = '';
                  searchResultList = [];
                });
              },
              onSubmitted: (value) async {
                query = value.toString();
                setState(() {
                  if(value.isNotEmpty) {
                    isSearched = true;
                  }
                  if(!historyList.contains(value)) {
                    historyList.add(value);
                    prefs.setStringList('historyList', historyList);
                  }
                }
                );},
              queryController: queryController,
              focusNode: focusNode,
            ),
          )
        ),
      ),
      drawer: DictDrawer(),
      body: isSearched
          ? FutureBuilder(
            future: searchFuture(),
            builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
              if(snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Colors.blueAccent,
                  ),
                );
              }
              else {
                return Column(
                  children: [
                    Container(
                      height: 10,
                    ),
                    searchResultList.isEmpty ? Card(
                      color: themeModeProvider.isDarkTheme ? Colors.white10 : Theme.of(context).dialogBackgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4), // 设置圆角半径为10
                      ),
                      margin: EdgeInsets.only(top: 5, left: 10, right: 10),
                      child: ListTile(
                        contentPadding: EdgeInsets.only(left: 20, right: 20),
                        leading: Icon(Icons.travel_explore),
                        // 条目标题
                        title: Text(query.toString() + "を見つけないでした", overflow: TextOverflow.ellipsis, maxLines: 1),
                        // 条目介绍
                        subtitle: Text('ウェブページ検索', overflow: TextOverflow.ellipsis, maxLines: 1),
                        onTap: () {
                          // 网页搜索
                          openURL(Uri.parse('https://www.google.com/search?q=' + query.toString()));
                        },
                      )
                    )
                    : Expanded(
                      child: ListView.builder(
                        itemCount: searchResultList!.length,
                        itemBuilder: (context, index) {
                          return SearchResultListItem(searchResultList: searchResultList, index: index);
                        },
                      ),
                    ),
                  ],
                );
              }
            }
          )
          : (historyList.isEmpty ? Container(child: Center(child: Text('何か検索しましょう～', style: TextStyle(fontSize: 20)))) : Column(
          children: <Widget>[
            Container(
              height: 30,
              margin: EdgeInsets.only(top: 5),
              padding: EdgeInsets.only(top: 1, bottom: 1, left: 5),
              color: Colors.blueAccent,
              child: Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('履歴', maxLines: 1, textAlign: TextAlign.left, style: TextStyle(fontSize: 15, color: Colors.white)),
                    ),
                  ),
                  Container(
                    width: 30,
                    height: 30,
                    padding: EdgeInsets.only(top: 0, right: 5, bottom: 0, left: 0),
                    child: IconButton(
                      icon: Icon(Icons.delete, color: Colors.white),
                      iconSize: 14,
                      splashRadius: 5,
                      onPressed: () {
                        // 删除历史记录
                        setState(() {
                          historyList = [];
                          prefs.setStringList('historyList', []);
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: historyList!.length,
                itemBuilder: (BuildContext context, int index) {
                  return HistoryListItem(
                    historyList: historyList,
                    index: index,
                    onPressed: () {
                      setState(() {
                        historyList.remove(historyList[index]);
                        prefs.setStringList('historyList', historyList);
                      });
                    },
                    onTap: () async {
                      query = historyList[index].toString();
                      queryController.text = query;
                      isSearched = true;
                      setState(() {

                      });
                    },
                  );
                },
              ),
            ),
          ]
        )
      )
    );
  }

  @override
  void dispose() {
    super.dispose();
    query = '';
    queryController.dispose();
    focusNode.dispose();
  }
}