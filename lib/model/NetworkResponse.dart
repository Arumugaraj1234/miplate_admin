import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:miplate/model/base/BaseNetworkResponse.dart';

class NetworkResponse {
  static String BASE_URL = 'http://64.15.141.244:80/Hotel/Rest/';
  //static String BASE_URL = 'http://64.15.141.244:80/Gurkha/WebApi/api/Admin/';

  static Future<JsonDecoder> getResponseJson(
      String api, Map<String, dynamic> jsonMapp) async {
    var finalUrl = BASE_URL + api;
    var response =
        await http.post(finalUrl, body: json.encode(jsonMapp), headers: {
      HttpHeaders.contentTypeHeader: "application/json",
    });
    var jsonDecoder = json
        .decode(utf8.decode(response.bodyBytes))
        .cast<Map<String, dynamic>>();
    return jsonDecoder;
  }
}
