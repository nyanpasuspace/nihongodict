import 'package:flutter/material.dart';
import 'package:nihongodict/common/global.dart';
import 'package:nihongodict/pages/tango_item_page.dart';

class SearchResultListItem extends StatefulWidget {
  final List<dynamic> searchResultList;
  final int index;
  const SearchResultListItem({
    Key? key,
    required this.searchResultList,
    required this.index,
  }) : super(key: key);
  @override
  _SearchResultListItemState createState() => _SearchResultListItemState();
}

class _SearchResultListItemState extends State<SearchResultListItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: themeModeProvider.isDarkTheme ? Colors.white10 : Colors.white70,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      margin: EdgeInsets.only(top: 5, left: 10, right: 10),
      child: ListTile(
        contentPadding: EdgeInsets.only(left: 20, right: 20),
        leading: Icon(Icons.cloud),
        title: Text(widget.searchResultList[widget.index]['heading'].toString().replaceAll('\n', '\n\n')
          .replaceFirst('[keyword]', '').replaceAll('[keyword]', '').replaceAll('[/keyword]', '')
          .replaceAll('[decoration]', '').replaceAll('[/decoration]', '')
          .replaceAll('[subscript]', '').replaceAll('[/subscript]', '')
          .replaceAll('{{zb468}}', '⇔'), overflow: TextOverflow.ellipsis, maxLines: 1),
        subtitle: Text(widget.searchResultList[widget.index]['text'].toString().replaceAll('\n', '').replaceAll('\n', '\n\n')
          .replaceFirst('[keyword]', '').replaceAll('[keyword]', '').replaceAll('[/keyword]', '')
          .replaceAll('[decoration]', '').replaceAll('[/decoration]', '')
          .replaceAll('[subscript]', '').replaceAll('[/subscript]', '')
          .replaceAll('[/image]オ', '[/image]')
          .replaceAll(RegExp(r'\[wav\s+page=(\d+),offset=(\d+),endpage=(\d+),endoffset=(\d+)\](.*?)\[/wav\]'), '')
          .replaceAll(RegExp(r'\[image\s+format=([A-Za-z]+),inline=(\d+),page=(\d+),offset=(\d+)\]([\s\S]*?)\[/image\]'), '')
          .replaceAll('{{zb468}}', '⇔'), overflow: TextOverflow.ellipsis, maxLines: 1),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TangoItemPage(
              searchResultList: searchResultList,
              index: widget.index,
            )),
          );
        },
      )
    );
  }
}
