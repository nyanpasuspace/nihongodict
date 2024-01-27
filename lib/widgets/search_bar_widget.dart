import 'package:flutter/material.dart';
import 'package:nihongodict/common/global.dart';

class SearchAppBar extends StatefulWidget {
  final Function() onTapOutside;
  final Function(String) onChanged;
  final Function() onClearAll;
  final Function(String) onSubmitted;
  final FocusNode focusNode;
  final TextEditingController queryController;
  SearchAppBar({
    Key? key,
    required this.onTapOutside,
    required this.onChanged,
    required this.onClearAll,
    required this.onSubmitted,
    required this.focusNode,
    required this.queryController,
  });
  @override
  State<StatefulWidget> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: AppBar().preferredSize.height * 0.1, bottom: AppBar().preferredSize.height * 0.1, left: 0, right: 0),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      height: AppBar().preferredSize.height * 0.8,
      alignment: Alignment.centerLeft,
      child: TextField(
        textInputAction: TextInputAction.search,
        style: TextStyle(fontFamily: 'Noto, Source Han Sans', height: 1.5, fontSize: 18),
        textAlignVertical: TextAlignVertical.center,
        maxLines: 1,
        minLines: 1,
        controller: widget.queryController,
        focusNode: widget.focusNode,
        autofocus: false,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.outline)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.outline)),
          hintText: '検索',
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(left: 10, right: 10),
          suffixIcon: widget.queryController.text.isEmpty ? null : IconButton(
            icon: Icon(Icons.close, size: 20),
            onPressed: () {
              setState(() {
                widget.queryController.clear();
                widget.onClearAll();
              });
            },
          ),
        ),
        onTap: () {

        },
        onTapOutside: (value) {
          widget.onTapOutside();
        },
        onChanged: (value) {
          widget.onChanged(value);
        },
        onSubmitted: (value) {
          // 搜索
          widget.onSubmitted(value);
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}