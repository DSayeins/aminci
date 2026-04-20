import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:aminci/core/error/exceptions.dart';
import 'package:aminci/core/mikrotik/router_os_response.dart';
import 'package:aminci/core/models/router.dart';

/// Client TCP pour le protocole RouterOS API (port 8728).
///
/// Chaque routeur MikroTik a sa propre instance de [RouterOsClient].
/// Appeler [connect] avant d'utiliser [send], ou laisser [send] se
/// connecter automatiquement (avec une tentative de reconnexion).
///
/// Protocole :
///   - Les données transitent sous forme de "mots" préfixés par leur longueur.
///   - Une "phrase" (sentence) est une suite de mots terminée par un mot vide.
///   - Le login supporte RouterOS v6 (challenge MD5) et v7+ (mot de passe direct).
class RouterOsClient {
  final String host;
  final int port;
  final String username;
  final String password;
  final RouterOsVersion rosVersion;
  final Duration commandTimeout;

  static const Duration _connectTimeout = Duration(seconds: 10);
  static const Duration _defaultCommandTimeout = Duration(seconds: 15);
  static const int _maxEmptySentences = 20;

  Socket? _socket;
  final Queue<int> _buffer = Queue();
  Completer<void>? _dataCompleter;
  bool _connected = false;
  bool _connecting = false; // FIX : protection appels concurrents

  RouterOsClient({
    required this.host,
    required this.port,
    required this.username,
    required this.password,
    this.rosVersion = RouterOsVersion.v7,
    this.commandTimeout = _defaultCommandTimeout,
  });

  factory RouterOsClient.fromRouter(MikroTikRouter router) => RouterOsClient(
    host: router.ip,
    port: router.port,
    username: router.username,
    password: router.password,
    rosVersion: router.rosVersion,
  );

  bool get isConnected => _connected;

  void _log(String msg) => debugPrint('[RouterOsClient $host:$port] $msg');

  // ---------------------------------------------------------------------------
  // Connexion / Déconnexion
  // ---------------------------------------------------------------------------

  Future<void> connect() async {
    if (_connected) return;

    // FIX : attendre si une connexion est déjà en cours
    if (_connecting) {
      while (_connecting) {
        await Future.delayed(const Duration(milliseconds: 20));
      }
      return;
    }

    _connecting = true;
    try {
      _socket = await Socket.connect(host, port).timeout(_connectTimeout);
      _buffer.clear();
      _dataCompleter = null;

      _socket!.listen(_onData, onError: _onSocketError, onDone: _onSocketDone, cancelOnError: false);

      await _login();
      _connected = true;
      _log('✓ Connecté');
    } on SocketException catch (e) {
      _socket = null;
      throw NetworkException('Connexion impossible à $host:$port — ${e.message}');
    } on TimeoutException {
      _socket = null;
      throw const NetworkException('Délai de connexion dépassé');
    } finally {
      // FIX : libérer le verrou même en cas d'erreur
      _connecting = false;
    }
  }

  Future<void> disconnect() async {
    _connected = false;
    _connecting = false;
    await _socket?.close();
    _socket = null;
    _buffer.clear();
    _log('Déconnecté');
  }

  // ---------------------------------------------------------------------------
  // API publique
  // ---------------------------------------------------------------------------

  /// Envoie une phrase RouterOS et retourne toutes les réponses.
  /// En cas d'erreur réseau, tente une reconnexion unique avant de propager.
  ///
  /// ```dart
  /// final result = await client.send([
  ///   '/ip/hotspot/user/print',
  ///   '?profile=basic',
  /// ]);
  /// if (result.hasError) throw MikroTikException(result.errorMessage!);
  /// final users = result.replies;
  /// ```
  Future<List<RouterOsResponse>> send(List<String> sentence) async {
    if (!_connected) await connect();

    try {
      _sendSentence(sentence);
      return await _readResponsesUntagged();
    } on NetworkException {
      // FIX : reconnexion unique en cas de coupure réseau
      _log('Connexion perdue — tentative de reconnexion...');
      _connected = false;
      await connect();
      _sendSentence(sentence);
      return await _readResponsesUntagged();
    }
  }

  // ---------------------------------------------------------------------------
  // Écriture
  // ---------------------------------------------------------------------------

  void _sendSentence(List<String> words) {
    for (final word in words) {
      _sendWord(word);
    }
    _socket!.add([0x00]);
    _socket!.flush();
  }

  void _sendWord(String word) {
    final bytes = utf8.encode(word);
    _socket!.add(_encodeLength(bytes.length));
    _socket!.add(bytes);
  }

  Uint8List _encodeLength(int len) {
    if (len < 0x80) {
      return Uint8List.fromList([len]);
    } else if (len < 0x4000) {
      return Uint8List.fromList([(len >> 8) | 0x80, len & 0xFF]);
    } else if (len < 0x200000) {
      return Uint8List.fromList([(len >> 16) | 0xC0, (len >> 8) & 0xFF, len & 0xFF]);
    } else if (len < 0x10000000) {
      return Uint8List.fromList([(len >> 24) | 0xE0, (len >> 16) & 0xFF, (len >> 8) & 0xFF, len & 0xFF]);
    } else {
      return Uint8List.fromList([0xF0, (len >> 24) & 0xFF, (len >> 16) & 0xFF, (len >> 8) & 0xFF, len & 0xFF]);
    }
  }

  // ---------------------------------------------------------------------------
  // Lecture
  // ---------------------------------------------------------------------------

  void _onData(List<int> data) {
    _buffer.addAll(data);
    if (_dataCompleter != null && !_dataCompleter!.isCompleted) {
      _dataCompleter!.complete();
      _dataCompleter = null;
    }
  }

  void _onSocketError(Object error) {
    _connected = false;
    _socket = null;
    _log('Erreur socket : $error');
    if (_dataCompleter != null && !_dataCompleter!.isCompleted) {
      _dataCompleter!.completeError(NetworkException('Erreur socket : $error'));
      _dataCompleter = null;
    }
  }

  void _onSocketDone() {
    _connected = false;
    _socket = null;
    _log('Connexion fermée par le routeur');
    if (_dataCompleter != null && !_dataCompleter!.isCompleted) {
      _dataCompleter!.completeError(const NetworkException('Connexion fermée par le routeur'));
      _dataCompleter = null;
    }
  }

  Future<void> _waitForData() async {
    if (_buffer.isNotEmpty) return;

    // FIX : réutiliser le completer existant si déjà en attente
    if (_dataCompleter != null && !_dataCompleter!.isCompleted) {
      await _dataCompleter!.future;
      return;
    }

    _dataCompleter = Completer<void>();
    await _dataCompleter!.future.timeout(
      commandTimeout,
      onTimeout: () => throw const MikroTikException('Délai de réponse dépassé'),
    );
  }

  Future<int> _readByte() async {
    await _waitForData();
    return _buffer.removeFirst();
  }

  Future<Uint8List> _readBytes(int count) async {
    while (_buffer.length < count) {
      await _waitForData();
    }
    final bytes = Uint8List(count);
    for (var i = 0; i < count; i++) {
      bytes[i] = _buffer.removeFirst();
    }
    return bytes;
  }

  Future<int> _readLength() async {
    final first = await _readByte();
    if (first < 0x80) return first;
    if (first < 0xC0) {
      final b = await _readByte();
      return ((first & 0x3F) << 8) | b;
    }
    if (first < 0xE0) {
      final rest = await _readBytes(2);
      return ((first & 0x1F) << 16) | (rest[0] << 8) | rest[1];
    }
    if (first < 0xF0) {
      final rest = await _readBytes(3);
      return ((first & 0x0F) << 24) | (rest[0] << 16) | (rest[1] << 8) | rest[2];
    }
    final rest = await _readBytes(4);
    return (rest[0] << 24) | (rest[1] << 16) | (rest[2] << 8) | rest[3];
  }

  Future<String> _readWord() async {
    final length = await _readLength();
    if (length == 0) return '';
    final bytes = await _readBytes(length);
    return utf8.decode(bytes);
  }

  Future<List<String>> _readSentence() async {
    final words = <String>[];
    while (true) {
      final word = await _readWord();
      if (word.isEmpty) break;
      words.add(word);
    }
    return words;
  }

  Map<String, String> _parseAttributes(List<String> words) {
    final map = <String, String>{};
    for (final word in words) {
      if (word.startsWith('=')) {
        final eq = word.indexOf('=', 1);
        if (eq != -1) map[word.substring(1, eq)] = word.substring(eq + 1);
      } else if (word.startsWith('.')) {
        final eq = word.indexOf('=');
        if (eq != -1) map[word.substring(0, eq)] = word.substring(eq + 1);
      }
    }
    return map;
  }

  // ---------------------------------------------------------------------------
  // Login
  // ---------------------------------------------------------------------------

  Future<void> _login() async {
    if (rosVersion == RouterOsVersion.v7) {
      await _loginV7();
    } else {
      await _loginV6();
    }
  }

  Future<void> _loginV7() async {
    _log('Login mode v7');
    _sendSentence(['/login', '=name=$username', '=password=$password']);
    final result = await _readResponsesUntagged();
    if (result.trap != null) {
      throw MikroTikException('Authentification échouée : ${result.trap!.message}');
    }
    _log('✓ Authentifié (v7)');
  }

  Future<void> _loginV6() async {
    _log('Login mode v6 — handshake MD5');
    _sendSentence(['/login']);
    final step1 = await _readResponsesUntagged();

    if (step1.trap != null) {
      throw MikroTikException('Login refusé : ${step1.trap!.message}');
    }

    final done = step1.done;
    if (done == null) throw const MikroTikException('Réponse de login inattendue');

    final challenge = done['ret'];
    if (challenge == null || challenge.isEmpty) {
      throw const MikroTikException('Challenge MD5 absent dans la réponse v6');
    }

    _log('Challenge reçu: $challenge');
    final response = _md5ChallengeResponse(password, challenge);
    _sendSentence(['/login', '=name=$username', '=response=$response']);

    final step2 = await _readResponsesUntagged();
    if (step2.trap != null) {
      throw MikroTikException('Authentification v6 échouée : ${step2.trap!.message}');
    }
    _log('✓ Authentifié (v6)');
  }

  // ---------------------------------------------------------------------------
  // Lecture des réponses
  // ---------------------------------------------------------------------------

  Future<List<RouterOsResponse>> _readResponsesUntagged() async {
    final responses = <RouterOsResponse>[];
    var emptySentenceCount = 0;

    while (true) {
      final sentence = await _readSentence();

      if (sentence.isEmpty) {
        // FIX : protection contre boucle infinie sur phrases vides
        emptySentenceCount++;
        if (emptySentenceCount >= _maxEmptySentences) {
          throw const MikroTikException('Trop de phrases vides — protocole inattendu');
        }
        continue;
      }

      emptySentenceCount = 0;
      final type = sentence.first;
      final attrs = _parseAttributes(sentence.skip(1).toList());

      switch (type) {
        case '!re':
          responses.add(RouterOsReply(attrs));
        case '!done':
          responses.add(RouterOsDone(attrs));
          return responses;
        case '!trap':
          // FIX : factory constructor avec catégorie typée
          responses.add(RouterOsTrap.fromAttributes(attrs));
          return responses;
        case '!fatal':
          _connected = false;
          await _socket?.close();
          _socket = null;
          responses.add(RouterOsFatal(attrs['message'] ?? sentence.skip(1).join(' ')));
          return responses;
        default:
          _log('Mot-type inconnu ignoré : $type');
      }
    }
  }

  // ---------------------------------------------------------------------------
  // MD5 challenge-response (RouterOS v6)
  // Format : "00" + MD5(0x00 || password_bytes || challenge_bytes)
  // ---------------------------------------------------------------------------

  String _md5ChallengeResponse(String pwd, String challenge) {
    final challengeBytes = _hexDecode(challenge);
    final pwdBytes = utf8.encode(pwd);

    final input = Uint8List(1 + pwdBytes.length + challengeBytes.length);
    input[0] = 0x00;
    input.setRange(1, 1 + pwdBytes.length, pwdBytes);
    input.setRange(1 + pwdBytes.length, input.length, challengeBytes);

    final digest = md5.convert(input);
    return '00${digest.toString()}';
  }

  Uint8List _hexDecode(String hex) {
    final result = Uint8List(hex.length ~/ 2);
    for (var i = 0; i < result.length; i++) {
      result[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return result;
  }
}
