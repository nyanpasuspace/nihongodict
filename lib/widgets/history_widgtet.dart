import 'package:flutter/material.dart';
import 'package:nihongodict/common/global.dart';

class HistoryListItem extends StatefulWidget {
  final List historyList;
  final int index;
  final Function() onPressed;
  final Function() onTap;
  const HistoryListItem({
    Key? key,
    required this.historyList,
    required this.index,
    required this.onPressed,
    required this.onTap,
  }) : super(key: key);
  @override
  _HistoryListItemState createState() => _HistoryListItemState();
}

class _HistoryListItemState extends State<HistoryListItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: themeModeProvider.isDarkTheme ? Colors.white10 : Colors.white70,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4), // 设置圆角半径为10
      ),
      margin: EdgeInsets.only(top: 5, left: 10, right: 10),
      child: ListTile(
        contentPadding: EdgeInsets.only(left: 20, right: 20),
        leading: Icon(Icons.history),
        title: Text(widget.historyList[widget.index], overflow: TextOverflow.ellipsis, maxLines: 1),
        trailing: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            widget.onPressed();
          },
        ),
        onTap: () {
          widget.onTap();
        },
      )
    );
  }
}
