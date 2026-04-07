import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

/// Generates globally unique positive 64-bit integer IDs.
///
/// Format (Snowflake-like):
/// - 41 bits: milliseconds since 2020-01-01 UTC
/// - 10 bits: device node id (persisted locally)
/// - 12 bits: per-millisecond sequence
class GlobalIdService {
  GlobalIdService._();

  static final GlobalIdService instance = GlobalIdService._();

  static const String _nodeIdPrefsKey = 'global_id_node_id';
  static final DateTime _customEpoch = DateTime.utc(2020, 1, 1);

  int? _nodeId;
  int _lastTimestamp = -1;
  int _sequence = 0;

  Future<int> nextId() async {
    final nodeId = await _getNodeId();
    var timestamp = _nowMillisSinceEpoch();

    if (timestamp == _lastTimestamp) {
      _sequence = (_sequence + 1) & 0xFFF; // 12 bits
      if (_sequence == 0) {
        while (timestamp <= _lastTimestamp) {
          timestamp = _nowMillisSinceEpoch();
        }
      }
    } else {
      _sequence = 0;
    }

    _lastTimestamp = timestamp;
    return (timestamp << 22) | (nodeId << 12) | _sequence;
  }

  Future<int> _getNodeId() async {
    if (_nodeId != null) {
      return _nodeId!;
    }

    final prefs = await SharedPreferences.getInstance();
    final persisted = prefs.getInt(_nodeIdPrefsKey);
    if (persisted != null && persisted >= 0 && persisted <= 1023) {
      _nodeId = persisted;
      return persisted;
    }

    final random = Random.secure();
    final generated = random.nextInt(1024);
    await prefs.setInt(_nodeIdPrefsKey, generated);
    _nodeId = generated;
    return generated;
  }

  int _nowMillisSinceEpoch() {
    final now = DateTime.now().toUtc();
    return now.millisecondsSinceEpoch - _customEpoch.millisecondsSinceEpoch;
  }
}
