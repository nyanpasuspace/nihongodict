import 'package:flutter/material.dart';
import '../common/global.dart';

class DictListItem extends StatefulWidget {
  final List dictList;
  final int index;
  const DictListItem({
    Key? key,
    required this.dictList,
    required this.index,
  }) : super(key: key);
  @override
  _DictListItemState createState() => _DictListItemState();
}

class _DictListItemState extends State<DictListItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Tooltip(
        message: widget.dictList[widget.index],
        child: ListTile(
          title: Text(widget.dictList[widget.index], maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.left, style: TextStyle(fontSize: 18)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
          trailing: widget.index == usingDictIndex ? Icon(Icons.check, color: Colors.blueAccent) : null,
          onTap: () {
            setState(() {
              usingDictIndex = widget.index;
              dictListener.value = usingDictIndex;
              prefs.setInt('usingDictIndex', usingDictIndex);
            });
          },
        ),
      ),
    );
  }
}