// http://20.96.176.30/?api=1&q=携帯&dict=広辞苑&type=0&romaji=1
// https://sakura-paris.org/About/%E5%BA%83%E8%BE%9E%E8%8B%91%E7%84%A1%E6%96%99%E6%A4%9C%E7%B4%A2/API
// http://20.96.176.30/?api=1&dict=%E5%BA%83%E8%BE%9E%E8%8B%91&page=14996&offset=1704
// http://20.96.176.30/dictname/content/page_offset/
// classname = dict-content

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nihongodict/common/global.dart';
// TODO 跳过 Cloudflare 真人检测（对于広辞苑無料検索）
class ApiTool {
  // url 解析器, 将传入 url 返回 uri 对象
  Uri urlParser(String url, Map<String, dynamic> props) {
    final uri = Uri.parse(url);
    String path = '/';
    if(uri.scheme == 'http') {
      return Uri.http(
        uri.host,
        path,
        props,
      );
    }
    else if(uri.scheme == 'https') {
      return Uri.https(
        uri.host,
        path,
        props,
      );
    }
    else {
      throw ArgumentError('不受支持的 URL scheme: ${uri.scheme}');
    }
  }

  // 获取该站点字典列表
  Future<List<String>> getDicts(String url) async {
    final targetUri = urlParser(url, {'api': '1'});
    late dynamic res;
    res = await http.get(targetUri).timeout(
      const Duration(seconds: 20),
      onTimeout: () {
        return http.Response('Error', 408);
      },
    );
    if(res.statusCode == 200) {
      final responseBody = jsonDecode(res.body);
      final map = Map<String, dynamic>();
      map['data'] = responseBody;
      final result = (map['data'] as List)!.map((item)=>item as String)!.toList();
      return result!;
    }
    else {
      return [];
    }
  }

  // 获取单个词
  Future<Map<String, dynamic>> getTango(String url) async {
    final uri = Uri.parse(url);
    // print('api: ${uri.queryParameters['api']}');
    // print('dict: ${uri.queryParameters['dict']}');
    // print('page: ${uri.queryParameters['page']}');
    // print('offset: ${uri.queryParameters['offset']}');
    // print(uri);
    try {
      final dynamic res = await http.get(uri).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          print("Error: 408");
          return http.Response('Error', 408);
        },
      );
      if(res.statusCode == 200) {
        late List<dynamic> responseBody;
        if(res.body == []) {
          responseBody = [{}];
        }
        else {
          print(jsonDecode(res.body).runtimeType);
          responseBody = jsonDecode(res.body);
        }
        return responseBody[0];
      }
      else {
        print(res.statusCode.toString());
      }
    }
    catch(e) {
      print(e);
    }
    return {};
  }

  // 搜索字典
  Future<Map<String, dynamic>> searchDict(String url, Map<String, dynamic> props) async {
    Map<String, dynamic> newProps = {'api': '1'};
    newProps.addAll(props);
    final uri = urlParser(url, newProps);
    // print(uri);
    late dynamic res;
    res = await http.get(uri).timeout(
    const Duration(seconds: 20),
      onTimeout: () {
        return http.Response('Error', 408);
      },
    );
    if(res.statusCode == 200) {
      late Map<String, dynamic> responseBody;
      // api 没有结果时返回空 []
      if(res.body == "[]") {
        responseBody = {};
      }
      else {
        responseBody = jsonDecode(res.body);
      }
      return responseBody;
    }
    else {
      return {};
    }
  }
}