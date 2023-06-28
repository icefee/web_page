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

  static Future<VideoData?> getVideoData(String id) async {
    Map? jsonMap = await getJson('$apiServer/api/video/$id');
    if (jsonMap != null) {
      ApiResponse<Map> response = ApiResponse.fromMap<Map>(jsonMap);
      if (response.code == 0) {
        VideoData data = VideoData.fromMap(response.data);
        return data;
      }
    }
    return null;
  }
}
