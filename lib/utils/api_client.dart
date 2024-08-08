import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:talk_box/utils/helper.dart';

class ApiClient {
  final Dio client;

  ApiClient(this.client);

  init() {
    final baseOptions = BaseOptions(
      connectTimeout: Duration(milliseconds: 100000),
      sendTimeout: Duration(milliseconds: 100000),
      receiveTimeout: Duration(milliseconds: 100000),
      receiveDataWhenStatusError: true,
      baseUrl: "https://secure.meshulam.co.il/api/light/server/1.0/",
    );

    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
    };
    baseOptions.headers = headers;
    client.options = baseOptions;
    if (kDebugMode) {
      client.interceptors.add(
        PrettyDioLogger(
            requestHeader: true,
            requestBody: true,
            responseBody: true,
            responseHeader: false,
            error: true,
            compact: true,
            maxWidth: 90),
      );
    }
  }

  Future<Response?> post(
    String url, {
    Map<String, String>? headers,
    body,
  }) async {
    try {
      return await client.post(
        url,
        data: body,
        options: Options(
          headers: headers,
        ),
      );
    } on DioError catch (error) {
      _handleDioError(error);
    } catch (e) {
      Helper.customSnakBar(
        title: 'خطأ',
        success: false,
        message: 'افحص الانترنتً',
      );
    }
    return null;
  }

  void _handleDioError(DioError error) {
    Helper.customSnakBar(
      title: 'خطأ',
      success: false,
      message: 'سوف نقوم بحل المشكلة قريباً',
    );
  }
}
