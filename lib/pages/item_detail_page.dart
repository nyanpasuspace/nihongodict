import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:nihongodict/common/global.dart';
import 'package:flutter/material.dart';
import 'package:dart_markdown/dart_markdown.dart';
import 'package:nihongodict/pages/ref_page.dart';
import 'package:url_launcher/url_launcher.dart';

class ItemDetailPage extends StatefulWidget {
  final Map<String, dynamic> wordData;
  const ItemDetailPage({
    Key? key,
    required this.wordData,
  }) : super(key: key);
  @override
  _ItemDetailPageState createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {

  @override
  Widget build(BuildContext context) {
    final data =  widget.wordData['text'].toString();
    final markdown = Markdown();
    final nodes = markdown.parse(
      contentConverter.parser(data),
    );
    final html = nodes.toHtml();
    return SelectionArea(
      child: Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 25),
          child: ListView(
            children: [
              HtmlWidget(
                html,
                customStylesBuilder: (e) {
                  if(e.localName == 'h2') {
                    return {
                      'font-size': '1.5em'
                    };
                  }
                  if(e.localName == 'p') {
                    return {
                      'font-size': '1.1em'
                    };
                  }
                  if(e.localName == 'a') {
                    return {
                      'color': '#007bff',
                      'text-decoration': 'none'
                    };
                  }
                  if(e.className == 'inline') {
                    return {
                      'display': 'inline-block'
                    };
                  }
                },
                customWidgetBuilder: (e) {
                  if(e.localName == 'img' && e.className.isEmpty) {
                    // 处理非注音图片
                    return Image.network(
                      e.attributes['src'].toString(),
                      fit: BoxFit.cover,
                    );
                  }
                },
                onTapUrl: (url) {
                  // 打开 url
                  launchUrl(Uri.parse(url));
                  // TODO 加载进入新页面: 收藏状态共享
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => RefItemPage(refUrl: url)
                  //   )
                  // );
                  return url.isNotEmpty;
                }
              ),
            ],
          )
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}