// import 'dart:developer';

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart' show debugPrint;

// import 'package:flutter/material.dart';
// import 'package:pretty_dio_logger/pretty_dio_logger.dart';

// import 'package:talker_flutter/talker_flutter.dart';

// implemneted singleton
class DioClient {
  DioClient();
  DioClient._();
  static final i = DioClient._();
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://192.168.0.140:6000/",
      responseType: ResponseType.json,
    ),
  );

  // void setupDioLogger() {
  //   // final talker = Talker();
  //   final logger = PrettyDioLogger(
  //     request: true,
  //     requestHeader: true,
  //     // requestBody: true,
  //     // responseHeader: true,
  //     responseBody: true,
  //     error: true,
  //     compact: true,
  //   );
  //   // log(logger.responseBody.toString())
  //   _dio.interceptors.add(logger);
  // }

  //Get Method
  Future<Map<String, dynamic>> get(String path,
      {Map<String, dynamic>? queryParameters,
      Options? options,
      CancelToken? cancelToken,
      ProgressCallback? onReceiveProgress}) async {
    try {
      // setupDioLogger();
      final Response response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      // if (response.statusCode == 200) {
      return response.data;
      // }
      // throw "something went wrong";
    } catch (e) {
      rethrow;
    }
  }

  ///Post Method
  Future<Map<String, dynamic>> post(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Options? options,
      CancelToken? cancelToken,
      ProgressCallback? onSendProgress,
      ProgressCallback? onReceiveProgress}) async {
    final Response response = await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> uploadWithFields(
    String path,
    File images, {
    Map<String, dynamic>? fields,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final FormData formData = FormData();

    formData.files.add(MapEntry(
      'client_image',
      await MultipartFile.fromFile(images.path),
    ));

    if (fields != null) {
      fields.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });
    }

    try {
      final Response response = await _dio.post(
        path,
        data: formData,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
