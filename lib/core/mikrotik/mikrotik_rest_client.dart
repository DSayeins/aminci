import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:aminci/core/error/exceptions.dart';

/// Client HTTP pour le protocole RouterOS REST API (MikroTik v7+).
///
/// Utilise HTTP Basic Auth sur le port 80 (HTTP) par défaut.
/// Les endpoints reproduisent la structure RouterOS :
///   GET    /rest/ip/hotspot/user          → liste
///   PUT    /rest/ip/hotspot/user          → créer
///   PATCH  /rest/ip/hotspot/user/*1       → modifier
///   DELETE /rest/ip/hotspot/user/*1       → supprimer
class MikroTikRestClient {
  final String host;
  final int port;
  final String username;
  final String password;

  static const Duration _timeout = Duration(seconds: 15);

  bool _connected = false;

  MikroTikRestClient({required this.host, required this.port, required this.username, required this.password});

  bool get isConnected => _connected;

  // ---------------------------------------------------------------------------
  // Connexion / Déconnexion
  // ---------------------------------------------------------------------------

  /// Valide la connexion REST en appelant /system/identity.
  Future<void> connect() async {
    debugPrint('[RestClient] Validation connexion http://$host:$port');
    try {
      await get('/system/identity');
      _connected = true;
      debugPrint('[RestClient] ✓ Connexion REST validée');
    } on MikroTikException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException('Connexion REST impossible à $host:$port — $e');
    }
  }

  Future<void> disconnect() async {
    _connected = false;
  }

  // ---------------------------------------------------------------------------
  // API publique
  // ---------------------------------------------------------------------------

  Future<dynamic> get(String path, {Map<String, String>? query}) => _request('GET', path, query: query);

  Future<dynamic> put(String path, Map<String, dynamic> body) => _request('PUT', path, body: body);

  Future<dynamic> patch(String path, Map<String, dynamic> body) => _request('PATCH', path, body: body);

  Future<void> delete(String path) async => _request('DELETE', path);

  // ---------------------------------------------------------------------------
  // Implémentation HTTP
  // ---------------------------------------------------------------------------

  Map<String, String> get _headers => {
    'Authorization': 'Basic ${base64Encode(utf8.encode('$username:$password'))}',
    'Content-Type': 'application/json',
  };

  Future<dynamic> _request(String method, String path, {Map<String, dynamic>? body, Map<String, String>? query}) async {
    final uri = Uri.http('$host:$port', '/rest$path', query);
    debugPrint('[RestClient] → $method $uri');

    final client = HttpClient();
    client.connectionTimeout = _timeout;

    try {
      final request = await client.openUrl(method, uri).timeout(_timeout);
      _headers.forEach((k, v) => request.headers.set(k, v));

      if (body != null) {
        final bytes = utf8.encode(jsonEncode(body));
        request.contentLength = bytes.length;
        request.add(bytes);
      }

      final response = await request.close().timeout(_timeout);
      return await _parse(response);
    } on SocketException catch (e) {
      throw NetworkException('Connexion impossible à $host:$port — ${e.message}');
    } on TimeoutException {
      throw const NetworkException('Délai de connexion dépassé');
    } catch (e) {
      if (e is NetworkException || e is MikroTikException) rethrow;
      throw NetworkException('Erreur HTTP inattendue : $e');
    } finally {
      client.close();
    }
  }

  Future<dynamic> _parse(HttpClientResponse response) async {
    final body = await response.transform(utf8.decoder).join();
    debugPrint(
      '[RestClient] ← ${response.statusCode} '
      '${body.length > 150 ? '${body.substring(0, 150)}…' : body}',
    );

    if (response.statusCode == 401) {
      throw const MikroTikException('Authentification REST échouée — vérifiez les identifiants');
    }
    if (response.statusCode >= 400) {
      dynamic json;
      try {
        json = jsonDecode(body);
      } catch (_) {}
      final msg = (json is Map ? (json['detail'] ?? json['message']) : null)?.toString() ?? body;
      throw MikroTikException('Erreur REST (${response.statusCode}): $msg');
    }

    if (body.isEmpty || response.statusCode == 204) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }
}
