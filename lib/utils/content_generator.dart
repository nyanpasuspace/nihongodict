import 'package:nihongodict/common/global.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlParser;
import 'package:html/dom.dart' as dom;
class ContentConverter {
  String contentUrlGenerator(Map<String, dynamic> item) {
    String page = item['page'].toString();
    String offset = item['offset'].toString();
    String targetUrl = siteUrl.endsWith('/') ? siteUrl + dictsList[usingDictIndex].toString() + '/content/' + '${page}_${offset}/' : siteUrl + '/' + dictsList[usingDictIndex].toString() + '/content/' + '${page}_${offset}/';
    return targetUrl;
  }

  // 一般来说，只处理 data['heading'] data['text']
  // 剔除无关内容, 类似加粗、无关紧要的链接
  String parser(String data) {
    RegExp refContentRegex = RegExp(r'\[reference\](.*?)\[/reference\s+page=(\d+),offset=(\d+)\]');
    RegExp audioContentRegex = RegExp(r'\[wav\s+page=(\d+),offset=(\d+),endpage=(\d+),endoffset=(\d+)\](.*?)\[/wav\]');
    RegExp imgContentRegex = RegExp(r'\[image\s+format=([A-Za-z]+),inline=(\d+),page=(\d+),offset=(\d+)\]([\s\S]*?)\[/image\]');
    data = data
      .replaceAll('\n', '\n\n')
      .replaceFirst('[keyword]', '## ').replaceAll('[keyword]', '').replaceAll('[/keyword]', '')
      .replaceAll('[decoration]', '**').replaceAll('[/decoration]', '**')
      .replaceAll('[subscript]', '<sub>').replaceAll('[/subscript]', '</sub>')
      .replaceAll('[superscript]', '<sup>').replaceAll('[/superscript]', '</sup>')
      .replaceAll('{{zb468}}', '⇔')
      .replaceAll('{{zb467}}', '⇔')
      .replaceAll('[/image]オ\n', '[/image]\n')
      // 去除注音图片
      .replaceAll(RegExp(r'\[image\s+format=([A-Za-z]+),inline=1,page=(\d+),offset=(\d+)\]([\s\S]*?)\[/image\]'), '')
    ;
    // 替换 reference 为链接
    String dataPlus = data.replaceAllMapped(refContentRegex, (match) {
      String? content = match.group(1);
      String? page = match.group(2);
      String? offset = match.group(3);
      String? apiUrl = siteUrl.endsWith('/') ? siteUrl + '?api=1&dict=${dictsList[usingDictIndex].toString()}&page=$page&offset=$offset' : siteUrl + '/' + '?api=1&dict=${dictsList[usingDictIndex].toString()}&page=$page&offset=$offset';
      return '[$content]($apiUrl)';
    });
    // 替换音频
    dataPlus = dataPlus.replaceAllMapped(audioContentRegex, (match) {
      String? content = match.group(5);
      String? page = match.group(1);
      String? offset = match.group(2);
      String? endpage = match.group(3);
      String? endoffset = match.group(4);
      String? audioUrl = siteUrl.endsWith('/') ? siteUrl + '${dictsList[usingDictIndex].toString()}' + '/binary/${page}_${offset}_${endpage}_${endoffset}' : siteUrl + '/' + '${dictsList[usingDictIndex].toString()}' + '/binary/${page}_${offset}_${endpage}_${endoffset}';
      String? src = "$audioUrl.mp3";
      // print('''<audio controls preload="none" title="$content" src="$src" type="audio/mpeg"></audio>''');
      // return '''<audio controls preload="metadata" title="$content" src="$src" type="audio/mpeg"></audio>''';
      return '';
    });
    // 替换图片
    dataPlus = dataPlus.replaceAllMapped(imgContentRegex, (match) {
      String? format = match.group(1);
      String? inline = match.group(2) == '1' ? 'inline' : '';
      String? page = match.group(3);
      String? offset = match.group(4);
      String? title = match.group(5);
      String? imgUrl = siteUrl.endsWith('/') ? siteUrl + '${dictsList[usingDictIndex].toString()}' + '/binary/${page}_${offset}.${format}': siteUrl + '/' + '${dictsList[usingDictIndex].toString()}' + '/binary/${page}_${offset}.${format}';
      // print('imgUrl: $imgUrl');
      // 处理换行导致的标签失效
      String? imgElement = '''<img class="$inline" title="$title" src="$imgUrl">''';
      imgElement = imgElement.replaceAll('\n', '');
      return imgElement;
    });
    return dataPlus;
  }
}