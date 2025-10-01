import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pepito_updates/config/api_config.dart';
import 'package:pepito_updates/models/pepito_activity.dart';
import 'package:pepito_updates/utils/logger.dart';
import 'package:pepito_updates/services/supabase_service.dart';

class SSEService {
  static final SSEService _instance = SSEService._internal();
  factory SSEService() => _instance;
  SSEService._internal();

  StreamController<PepitoActivity>? _activityController;
  StreamController<Map<String, dynamic>>? _heartbeatController;
  http.Client? _client;
  bool _isConnected = false;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 5);

  Stream<PepitoActivity> get activityStream {
    _activityController ??= StreamController<PepitoActivity>.broadcast();
    return _activityController!.stream;
  }

  Stream<Map<String, dynamic>> get heartbeatStream {
    _heartbeatController ??= StreamController<Map<String, dynamic>>.broadcast();
    return _heartbeatController!.stream;
  }

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_isConnected) {
      Logger.info('SSE ya está conectado');
      return;
    }

    // En web, evitar conexiones SSE por problemas de CORS
    if (kIsWeb) {
      Logger.info('SSE deshabilitado en web debido a limitaciones de CORS');
      return;
    }



    try {
      // Usar siempre cliente HTTP estándar para SSE con dominio
      _client = http.Client();

      final url = '${ApiConfig.baseUrl}${ApiConfig.sseEndpoint}';
      Logger.info('Conectando a SSE: $url');

      final request = http.Request('GET', Uri.parse(url));
      request.headers.addAll({
        'Accept': 'text/event-stream',
        'Cache-Control': 'no-cache',
      });

      final streamedResponse = await _client!.send(request);

      if (streamedResponse.statusCode == 200) {
        _isConnected = true;
        _reconnectAttempts = 0;
        Logger.info('Conexión SSE establecida exitosamente');

        streamedResponse.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .listen(
              _handleSSEData,
              onError: _handleError,
              onDone: _handleDisconnection,
            );
      } else {
        throw Exception('Error de conexión SSE: ${streamedResponse.statusCode}');
      }
    } catch (e) {
      Logger.error('Error al conectar SSE: $e');
      _handleError(e);
    }
  }

  void _handleSSEData(String data) {
    if (data.trim().isEmpty) return;
    
    try {
      // Manejar formato SSE estándar: "data: {json}"
      String jsonString = data;
      if (data.startsWith('data: ')) {
        jsonString = data.substring(6); // Remover "data: "
      } else if (data.startsWith('data:')) {
        jsonString = data.substring(5); // Remover "data:"
      }
      
      // Ignorar líneas que no contienen JSON válido
      if (jsonString.trim().isEmpty || !jsonString.trim().startsWith('{')) {
        return;
      }
      
      final jsonData = jsonDecode(jsonString);
      
      if (jsonData is Map<String, dynamic>) {
        final event = jsonData['event'] as String?;
        
        switch (event) {
          case 'pepito':
            _handlePepitoEvent(jsonData);
            break;
          case 'heartbeat':
            _handleHeartbeatEvent(jsonData);
            break;
          default:
            Logger.debug('Evento SSE desconocido: $event');
        }
      }
    } catch (e) {
      Logger.error('Error procesando datos SSE: $e');
    }
  }

  void _handlePepitoEvent(Map<String, dynamic> data) {
    try {
      final activity = PepitoActivity(
        event: data['event'] ?? 'pepito',
        type: data['type'] ?? '',
        timestamp: data['time'] ?? 0,
        img: data['img'],
      );
      
      _activityController?.add(activity);
      Logger.info('Nueva actividad de Pépito: ${activity.type}');
      
      // Guardar automáticamente en Supabase
    _saveToSupabase(activity);
    } catch (e) {
      Logger.error('Error procesando evento de Pépito: $e');
    }
  }
  
  void _saveToSupabase(PepitoActivity activity) async {
    try {
      final supabaseService = SupabaseService();
      await supabaseService.logStatusUpdate(activity);
      Logger.info('Actividad guardada en Supabase desde SSE: ${activity.type}');
    } catch (e) {
      Logger.error('Error guardando actividad en Supabase desde SSE: $e');
    }
  }

  void _handleHeartbeatEvent(Map<String, dynamic> data) {
    _heartbeatController?.add(data);
    Logger.debug('Heartbeat recibido: ${data['time']}');
  }

  void _handleError(dynamic error) {
    Logger.error('Error en SSE: $error');
    _isConnected = false;
    _scheduleReconnect();
  }

  void _handleDisconnection() {
    Logger.warning('Conexión SSE cerrada');
    _isConnected = false;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      Logger.error('Máximo número de intentos de reconexión alcanzado');
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, () {
      _reconnectAttempts++;
      Logger.info('Intento de reconexión #$_reconnectAttempts');
      connect();
    });
  }

  Future<void> disconnect() async {
    Logger.info('Desconectando SSE');
    _isConnected = false;
    _reconnectTimer?.cancel();
    _client?.close();
    _client = null;
  }

  void dispose() {
    disconnect();
    _activityController?.close();
    _heartbeatController?.close();
    _activityController = null;
    _heartbeatController = null;
  }
}