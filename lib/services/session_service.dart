import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constant/variables.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  // Session state
  bool _isSessionActive = false;
  DateTime? _sessionStartTime;
  DateTime? _sessionEndTime;
  Timer? _sessionTimer;

  // Getters
  bool get isSessionActive => _isSessionActive;
  DateTime? get sessionStartTime => _sessionStartTime;
  DateTime? get sessionEndTime => _sessionEndTime;

  // Stream controller for session status changes
  final StreamController<bool> _sessionStatusController = StreamController<bool>.broadcast();
  Stream<bool> get sessionStatusStream => _sessionStatusController.stream;

  // Initialize session monitoring
  Future<void> initializeSession() async {
    await _checkSessionStatus();
    _startSessionTimer();
  }

  // Check current session status
  Future<bool> _checkSessionStatus() async {
    try {
      var response = await http.get(Uri.parse(
          '${Variables.baseUrl}/api/v2/pages/?type=product.BranchIndexPage&fields=*'));
      
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(response.body);
        var items = jsonData['items'];
        
        if (items.isNotEmpty) {
          var startDate = DateTime.parse(items[0]['start_bidding_session']);
          var endDate = DateTime.parse(items[0]['end_bidding_session']);
          var currentDate = DateTime.now();

          _sessionStartTime = startDate;
          _sessionEndTime = endDate;

          // Check if session is active
          bool wasActive = _isSessionActive;
          _isSessionActive = currentDate.isAfter(startDate) && currentDate.isBefore(endDate);

          // Notify listeners if status changed
          if (wasActive != _isSessionActive && !_sessionStatusController.isClosed) {
            _sessionStatusController.add(_isSessionActive);
          }

          return _isSessionActive;
        }
      }
    } catch (e) {
      print('Error checking session status: $e');
    }
    
    _isSessionActive = false;
    if (!_sessionStatusController.isClosed) {
      _sessionStatusController.add(_isSessionActive);
    }
    return false;
  }

  // Start timer to periodically check session status
  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (!_sessionStatusController.isClosed) {
        _checkSessionStatus();
      } else {
        timer.cancel();
      }
    });
  }

  // Get time remaining until session starts/ends
  Duration? getTimeUntilSessionStart() {
    if (_sessionStartTime == null) return null;
    return _sessionStartTime!.difference(DateTime.now());
  }

  Duration? getTimeUntilSessionEnd() {
    if (_sessionEndTime == null) return null;
    return _sessionEndTime!.difference(DateTime.now());
  }

  // Get session status text
  String getSessionStatusText() {
    if (_sessionStartTime == null || _sessionEndTime == null) {
      return 'Session data unavailable';
    }

    final now = DateTime.now();
    final timeUntilStart = _sessionStartTime!.difference(now);
    final timeUntilEnd = _sessionEndTime!.difference(now);

    if (timeUntilStart.isNegative && timeUntilEnd.isNegative) {
      return 'Session Ended';
    } else if (timeUntilStart.isNegative && !timeUntilEnd.isNegative) {
      return 'Live Now - Ends in ${_formatDuration(timeUntilEnd)}';
    } else {
      return 'Starts in ${_formatDuration(timeUntilStart)}';
    }
  }

  // Get session status color
  String getSessionStatusColor() {
    if (_sessionStartTime == null || _sessionEndTime == null) {
      return 'grey';
    }

    final now = DateTime.now();
    final timeUntilStart = _sessionStartTime!.difference(now);
    final timeUntilEnd = _sessionEndTime!.difference(now);

    if (timeUntilStart.isNegative && timeUntilEnd.isNegative) {
      return 'red';
    } else if (timeUntilStart.isNegative && !timeUntilEnd.isNegative) {
      return 'green';
    } else {
      return 'orange';
    }
  }

  // Format duration for display
  String _formatDuration(Duration duration) {
    if (duration.isNegative) {
      return '0m 0s';
    }
    
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m ${seconds}s';
    }
  }

  // Force refresh session status
  Future<bool> refreshSessionStatus() async {
    return await _checkSessionStatus();
  }

  // Dispose resources
  void dispose() {
    _sessionTimer?.cancel();
    if (!_sessionStatusController.isClosed) {
      _sessionStatusController.close();
    }
  }
}
