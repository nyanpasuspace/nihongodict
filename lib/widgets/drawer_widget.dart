import 'package:flutter/material.dart';
import 'package:nihongodict/widgets/dict_widget.dart';

import '../common/global.dart';

class DictDrawer extends StatefulWidget {
  const DictDrawer({
    Key? key,
  }) : super(key: key);
  @override
  _DictDrawerState createState() => _DictDrawerState();
}

class _DictDrawerState extends State<DictDrawer> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: dictListener,
      builder: (BuildContext context, int value, Widget? child) {
        return Container(
          width: MediaQuery.of(context).size.width * 3 / 5,
            child: Drawer(
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 0, top: 30),
                    padding: EdgeInsets.only(bottom: 5),
                    height: 50,
                    child: ListTile(
                      title: Text(
                        'すべての辞典',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                    padding: EdgeInsets.only(top: 10),
                    itemCount: dictsList!.length,
                    itemBuilder: (context, index) {
                      return DictListItem(
                        dictList: dictsList,
                        index: index,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}