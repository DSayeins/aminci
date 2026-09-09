import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:aminci/core/mikrotik/mikrotik_exception.dart';

class MikroTikRestClient {
  MikroTikRestClient({required String ip, required int port, required String username, required String password})
    : _dio = Dio(
        BaseOptions(
          baseUrl: 'http://$ip:$port/rest',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Authorization': 'Basic ${base64Encode(utf8.encode('$username:$password'))}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

  final Dio _dio;

  /// Valide la connexion via GET /rest/system/identity.
  /// Lance [MikroTikException] si la connexion échoue.
  Future<void> connect() async {
    await get('/system/identity');
  }

  Future<List<Map<String, dynamic>>> get(String path) async {
    try {
      final response = await _dio.get<dynamic>(path);
      final data = response.data;
      if (data is List) return data.cast<Map<String, dynamic>>();
      if (data is Map<String, dynamic>) return [data];
      return [];
    } on DioException catch (e) {
      throw _toMikroTikException(e);
    }
  }

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) async {
    try {
      final response = await _dio.put<dynamic>(path, data: body);
      return (response.data as Map<String, dynamic>?) ?? {};
    } on DioException catch (e) {
      throw _toMikroTikException(e);
    }
  }

  Future<Map<String, dynamic>> patch(String path, Map<String, dynamic> body) async {
    try {
      final response = await _dio.patch<dynamic>(path, data: body);
      return (response.data as Map<String, dynamic>?) ?? {};
    } on DioException catch (e) {
      throw _toMikroTikException(e);
    }
  }

  Future<void> delete(String path) async {
    try {
      await _dio.delete<dynamic>(path);
    } on DioException catch (e) {
      throw _toMikroTikException(e);
    }
  }

  void close() => _dio.close(force: false);

  // ---------------------------------------------------------------------------

  MikroTikException _toMikroTikException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return MikroTikException(message: 'Connexion impossible : ${e.message}');
    }

    final statusCode = e.response?.statusCode;
    if (statusCode == 401) {
      return const MikroTikException(statusCode: 401, message: 'Identifiants incorrects');
    }

    final detail = _extractError(e.response?.data);
    return MikroTikException(statusCode: statusCode, message: detail);
  }

  String _extractError(dynamic data) {
    if (data is Map<String, dynamic>) {
      return (data['detail'] ?? data['message'] ?? 'Erreur inconnue').toString();
    }
    return data?.toString().isNotEmpty == true ? data.toString() : 'Erreur inconnue';
  }
}
