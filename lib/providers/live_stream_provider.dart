import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

final liveScoreStreamProvider = StreamProvider<Map<String, dynamic>>((ref) async* {
  final apiService = ref.watch(apiServiceProvider);
  
  // Dynamically resolve the WebSocket URL from the HTTP client base URL
  String wsUrl = 'ws://localhost:8080/ws/live';
  try {
    final httpUri = Uri.parse(apiService.baseUrl);
    final scheme = httpUri.scheme == 'https' ? 'wss' : 'ws';
    final host = httpUri.host.isNotEmpty ? httpUri.host : 'localhost';
    final port = httpUri.port > 0 ? httpUri.port : 8080;
    wsUrl = '$scheme://$host:$port/ws/live';
  } catch (e) {
    developer.log('Failed to parse WS URL, using default: $e');
  }

  developer.log('Connecting to Live WebSocket: $wsUrl');
  
  WebSocket? socket;
  try {
    socket = await WebSocket.connect(wsUrl).timeout(const Duration(seconds: 5));
  } catch (e) {
    developer.log('WebSocket connection failed: $e');
  }

  if (socket == null) {
    developer.log('Fallback: Launching local simulated updates stream.');
    final controller = StreamController<Map<String, dynamic>>();
    
    double niftyPrice = 24512.20;
    int runs = 186;
    int wickets = 4;
    double overs = 15.2;
    int footballHomeScore = 2;
    int footballAwayScore = 1;
    int footballMinutes = 72;
    
    final timer = Timer.periodic(const Duration(seconds: 4), (t) {
      if (controller.isClosed) return;
      
      // Simulate Nifty tick
      niftyPrice += (t.tick % 2 == 0 ? 3.5 : -2.1);
      controller.add({
        'type': 'finance',
        'id': 'NIFTY 50',
        'value': niftyPrice.toStringAsFixed(2),
        'change': '+1.24%',
      });

      // Simulate cricket tick
      if (t.tick % 3 == 0) {
        runs += 4;
      } else {
        runs += 1;
      }
      overs += 0.1;
      if (overs - overs.floor() >= 0.6) {
        overs = overs.floor() + 1.0;
      }
      controller.add({
        'type': 'cricket',
        'id': 'sports_demo',
        'score': '$runs/$wickets',
        'overs': overs.toStringAsFixed(1),
        'status': 'LIVE - Mumbai Strikers match progress',
      });

      // Simulate football tick
      if (t.tick % 3 == 0) {
        if (t.tick % 6 == 0) {
          footballHomeScore += 1;
        } else {
          footballAwayScore += 1;
        }
      }
      footballMinutes += 1;
      if (footballMinutes > 90) {
        footballMinutes = 1;
        footballHomeScore = 0;
        footballAwayScore = 0;
      }
      controller.add({
        'type': 'football',
        'id': 'football_demo',
        'score': '$footballHomeScore - $footballAwayScore',
        'status': 'Second Half - $footballMinutes\'',
      });
    });

    ref.onDispose(() {
      timer.cancel();
      controller.close();
    });

    yield* controller.stream;
    return;
  }

  ref.onDispose(() {
    socket?.close();
  });

  await for (final message in socket) {
    try {
      final decoded = jsonDecode(message.toString()) as Map<String, dynamic>;
      yield decoded;
    } catch (e) {
      developer.log('Error parsing WS message: $e');
    }
  }
});
