import 'package:http/http.dart';
import 'dart:convert';
import './type.dart';
export './type.dart';

class Http {
  static bool isDev = const bool.fromEnvironment('DEBUG', defaultValue: false);

  static String apiServer = isDev ? 'http://localhost:3000' : '';

  static Future<Map?> getJson(String url) async {
    try {
      Response response = await get(Uri.parse(url));
      String json = utf8.decode(response.bodyBytes);
      Map data = jsonDecode(json);
      return data;
    } catch (err) {
      return null;
    }
  }

  static Future<T?> getApiJson<T>(String url) async {
    try {
      Map? jsonMap = await getJson(url);
      if (jsonMap == null) {
        throw 'network error';
      }
      ApiResponse<T> result = ApiResponse.fromMap<T>(jsonMap);
      if (result.code == 0) {
        return result.data;
      } else {
        throw result.msg;
      }
    } catch (err) {
      return null;
    }
  }

  static Future<VideoData?> getVideoData(String id) async {
    Map? data = await getApiJson<Map>('$apiServer/api/video/$id');
    return data != null ? VideoData.fromMap(data) : null;
  }

  static Future<String?> parseVideoUrl(String url) => getApiJson<String>('$apiServer/api/video/parse?url=$url');
}
